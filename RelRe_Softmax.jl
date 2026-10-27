using CSV, Dates, DataFrames, Distributions, NLopt, ArgParse
#julia --threads 5 RelRe_Softmax.jl -b baseline -s 2020-01-01 -e 2021-01-01  

#Pull in information from command line arguments
s = ArgParseSettings()
@add_arg_table s begin
    "--in", "-i"
    arg_type = String
    required = true
    help = "input file containing temporal count data of variants"
    "--out", "-o"
    arg_type = String
    default = ""
    help = "prefix of output files"
    # add --values, -v option for giving initial values of optimisation. Set the default value to "".
    "--values", "-v"
    arg_type = String
    default = ""
    help = "for giving initial values of optimisation"
    "--start", "-s"
    arg_type = String
    default = ""
    help = "start date of the analysis"
    "--end", "-e"
    arg_type = String
    default = ""
    help = "end date of the analysis"
    "--future", "-f"
    arg_type = Int64
    default = 0
    help = "duration in days for predicting variant frequencies"
    "--baseline", "-b"
    arg_type = Symbol
    required = true
    help = "variant used as the baseline of relative reproduction numbers"
    "--subjects", "-j"
    arg_type = Symbol
    nargs = '*'
    default = []
    help = "list of variants to calculate relative reproduction numbers"
    "--ftol_abs"
    arg_type = Float64
    default = 0.0
    help = "stopping criterion used as ftol_abs in NLopt"
    "--ftol_rel"
    arg_type = Float64
    default = 1e-8
    help = "stopping criterion used as ftol_rel in NLopt"
    "--maxeval"
    arg_type = Int64
    default = 5_000_000
    help = "stopping criterion used as maxeval in NLopt"
    "--division", "-d"
    arg_type = Int64
    default = 1
    help = "the number of calculation time steps in one day"
    "--estimate_CI", "-c"
    action = :store_true
    help = "estimate 95% confidence intervals"
    "--undetected", "-u"
    action = :store_true
    help = "assume all variants exist undetected from the start date"
    "--blocks", "-r"
    arg_type = Int64 
    nargs = '*'
    default = []
    help = "a vector indicating variants sharing same reproduction numbers"
    "--model_selection", "-k"
    arg_type = String
    required = true
    help = "criterion for model selection (choose AIC or BIC)"
end
parsed_args = parse_args(ARGS, s)
@show parsed_args

#Init variables
const infile = parsed_args["in"]
const outfile_prefix = parsed_args["out"]
const valuefile = parsed_args["values"]
const ftol_abs = parsed_args["ftol_abs"]
const ftol_rel = parsed_args["ftol_rel"]
const maxeval = parsed_args["maxeval"]
const baseline = parsed_args["baseline"]
const start_date = parsed_args["start"]
const end_date = parsed_args["end"]
const arg_subjects = parsed_args["subjects"]
const estimate_CI = parsed_args["estimate_CI"]
const assume_undetected = parsed_args["undetected"]
const division = parsed_args["division"]
const delta = 1.0
const arg_blocks = parsed_args["blocks"]
const model_sel = parsed_args["model_selection"]

function log_softmax(x)
    m = maximum(x)
    return x .- m .- log(sum(exp.(x .- m)))
end

function model_q(vec_b1, vec_b0, t_s, t_e)

    @assert length(vec_b1) == num_subjects
    @assert length(vec_b0) == num_subjects

    T = eltype(vec_b1)
    duration = (t_e - t_s).value + 1

    mat_q = Matrix{T}(undef, duration, num_subjects + 1)

    for day_t in 1:duration
        vec_x = vcat(vec_b0 .+ vec_b1 .* (day_t - 1), zero(T))
        mat_q[day_t,:] .= exp.(log_softmax(vec_x))
    end

    return mat_q
end

#Main
#Check for values provided in program options

#Load in specified matrix file
println("Loading counts")
df_count = DataFrame(CSV.File(infile))

#Check whether the first two columns are vectors of dates
if(typeof(df_count[:,1])!=Vector{Date})
    error("The first column is not a vector of dates")
end
if(typeof(df_count[:,2])!=Vector{Date})
    error("The second column is not a vector of dates")
end

#Check the names of the first two columns
if(propertynames(df_count)[1]!=:date_from)
    error("The name of the first column must be date_from")
end
if(propertynames(df_count)[2]!=:date_till)
    error("The name of the second column must be date_till")
end

#Check whether the input table has counts of the baseline variant
if !(baseline in propertynames(df_count)[3:size(df_count,2)])
    error("Counts of the baseline variant can't be found in the table")
end
println("\nBaseline")
println(baseline)

#Specify variants as all, and remove baseline from subjects
if(arg_subjects == [])
    variants = propertynames(df_count)[3:size(df_count,2)]
    subjects = filter(x -> x != baseline, variants)
else
    if !issubset(arg_subjects, propertynames(df_count)[3:size(df_count,2)])
        error("Counts of a subject can't be found in the table")
    else
        subjects = arg_subjects
        variants = vcat(subjects, baseline)
    end
end

println("\nSubject clades")
const num_subjects = length(subjects)
@show(subjects)

dict_index = Dict{Symbol,Int64}()
map(x -> dict_index[subjects[x]] = x, 1:length(subjects))
dict_index[baseline] = length(subjects) + 1

#Determine the date for t_end
if(end_date != "")
    const t_end = Date(end_date)
    if !(t_end in df_count.date_till)
        println("error: The end date should be a day in the date_till column")
        exit(1)
    end
else
    const t_end = maximum(df_count.date_till)
end

#Determine the date for t_start
if(start_date != "")
    const t_start = Date(start_date)
    if !(t_start in df_count.date_from)
        println("error: The start date should be a day in the date_from column")
        exit(1)
    end
else
    const t_start = minimum(df_count.date_from)
end

#Check whether the start date is earlier than the end date
if(t_start >= t_end)
    println("error: The start date should be earlier than the end date")
    exit(1)
end

#Remove data before start date or after end date
deleteat!(df_count, df_count.date_till .< t_start)
deleteat!(df_count, df_count.date_from .> t_end)

@show(df_count)

#Record the date of variant's first observation during the period 
dict_first = Dict{Symbol,Date}()
if assume_undetected
    map(v -> dict_first[v] = t_start, variants)
else
    map(v -> dict_first[v] = minimum(filter(v => n -> n > 0, df_count).date_from), variants)
end

println("\nTime range of analysis")
println("Start: " * Dates.format(t_start, ISODateFormat))
println("End: " * Dates.format(t_end, ISODateFormat))

dates_from = df_count.date_from
dates_till = df_count.date_till
mat_obs = Matrix(df_count[:, vcat(subjects, baseline)])

#read initial values from the file if the file name is given 
if valuefile != ""
    @assert isfile(valuefile) == true 
    println("Loading initial values")
    df_values = DataFrame(CSV.File(valuefile))
end

function negLogL(par::Vector)
    vec_b1_tmp = par[1:num_k]
    vec_b1 = map(x -> x == 0 ? 0.0 : vec_b1_tmp[x], vec_blocks)
    vec_b0 = par[num_k+1 : num_k+num_subjects]

    try
        q = model_q(vec_b1, vec_b0, t_start, t_end)
        sumll = 0.0

        for i in 1:length(dates_from)
            obs = mat_obs[i,:]
            if(sum(obs) == 0)
                continue
            end

            t_idx = Dates.value(dates_from[i] - t_start) + 1
            probs = vec(q[t_idx, 1:num_subjects+1])
            probs = probs ./ sum(probs)
            sumll += logpdf(Multinomial(sum(obs), probs), obs)
        end

        if !isfinite(sumll)
            println("Warning: sumll is not finite")
            return floatmax(Float64)
        end

        return -sumll

    catch e
        println(e)
        exit(1)
    end
end

function is_restricted_growth(vec::Vector{Int64})
    if vec[1] != 0 
        return false
    end

    for i in 2:length(vec)
        if (vec[i] > 1 + maximum(vec[1:(i-1)]) || vec[i] < 0)
            return false
        end
    end

    return true
end

function grad_negLogL(par::Vector)
    
    vec_b1_tmp = par[1:num_k]
    vec_b0 = par[num_k+1 : num_k+num_subjects]
    vec_b1 = map(x -> x == 0 ? 0.0 : vec_b1_tmp[x], vec_blocks)

    q = model_q(vec_b1, vec_b0, t_start, t_end)

    grad_b1 = zeros(num_k)
    grad_b0 = zeros(num_subjects)

    for i in 1:length(dates_from)
        obs = mat_obs[i,:]
        N_total = sum(obs)

        if N_total == 0
            continue
        end

        t_idx = Dates.value(dates_from[i] - t_start) + 1
        probs = vec(q[t_idx, 1:num_subjects+1])
        probs = probs ./ sum(probs)

        # intercept gradients 
        for l in 1:num_subjects
            grad_b0[l] += obs[l] - N_total * probs[l]
        end

        # slope gradients
        for l in 1:num_subjects
            k = vec_blocks[l]
            if k == 0
                continue
            end
            grad_b1[k] += (obs[l] - N_total * probs[l]) * (t_idx - 1)
        end
    end

    return -vcat(grad_b1, grad_b0)
end

if length(arg_blocks) == 0
    vec_blocks = collect(1:num_subjects)
else
    if length(arg_blocks) != num_subjects + 1
        println("Error: The length of the blocks vector should be the same as the number of variants")
        exit(1)
    end 

    if maximum(arg_blocks) > num_subjects
        println("Error:The maximum number in the blocks vector should be smaller than or equal to the number of subjects")
        exit(1)
    end

    if minimum(arg_blocks) != 0 
        println("Error:The minimum number in the blocks vector should be 0")
        exit(1)
    end

    if is_restricted_growth(arg_blocks) == false
        println("Error: The blocks vector should be a restricted growth string")
        exit(1)
    end

    vec_blocks = arg_blocks[2:length(arg_blocks)]
end

@show vec_blocks
num_k = maximum(vec_blocks)

#use mean values for initial values of a group
# note that the length of the vector is num_k and not num_subjects
if valuefile != ""
    b1_vals = df_values.b1[2:end]
    vec_b1_start = fill(0.0, num_k)

    for i in 1:num_k
        indices = findall(x -> x == i, vec_blocks)
        mean_val = mean(b1_vals[indices])
        vec_b1_start[i] = mean_val
    end

    vec_b1_lb = fill(-30.0, num_k)
    vec_b1_ub = fill(30.0, num_k)
    vec_b0_start = df_values.b0[2:end]
    vec_b0_lb = fill(-30.0, num_subjects)
    vec_b0_ub = fill(30.0, num_subjects)

    @show vec_b1_start vec_b0_start
else
    vec_b1_start = fill(0.0, num_k)
    vec_b1_lb = fill(-30.0, num_k)
    vec_b1_ub = fill(30.0, num_k)
    vec_b0_start = fill(0.0, num_subjects)
    vec_b0_lb = fill(-30.0, num_subjects)
    vec_b0_ub = fill(30.0, num_subjects)
end

par_start = vcat(vec_b1_start, vec_b0_start)
par_lb = vcat(vec_b1_lb, vec_b0_lb)
par_ub = vcat(vec_b1_ub, vec_b0_ub)

function obj(par, grad)
    if length(grad) > 0
        grad[:] = grad_negLogL(par)
    end
    return negLogL(par)
end

opt = Opt(:LD_LBFGS, length(par_start))
opt.min_objective = obj
opt.lower_bounds = par_lb
opt.upper_bounds = par_ub
opt.ftol_abs = ftol_abs
opt.ftol_rel = ftol_rel
opt.maxeval = maxeval

println("Maximizing the likelihood function")
nmaxll, par_maxll, err = optimize(opt, par_start)
println("Maximization finished")

println(par_maxll)
println(-nmaxll)
println(err)

#Confidence Intervals
function constr(vec_par, vec_grad)

    if length(vec_grad) > 0
        vec_grad[:] = grad_negLogL(vec_par)
    end

    return -quantile(Chisq(1), 0.95)/2 - nmaxll + negLogL(vec_par)
end

function f1(par, grad, i)
    for x = 1:length(grad)
        grad[x] = (x == i) ? 1.0 : 0.0
    end
    par[i]
end

function f2(par, grad, i)
    for x = 1:length(grad)
        grad[x] = (x == i) ? -1.0 : 0.0
    end
    -par[i]
end

num_params = length(par_maxll)
num_loop = num_params * 2    
mat_95CI = Matrix{Float64}(undef, num_loop, num_params)
err_95CI = Vector{Symbol}(undef, num_loop)

if estimate_CI
    println("\nCalculating 95% confidence intervals (CIs)")
    
    Threads.@threads for i in 1:num_loop
        println("Thread " * string(Threads.threadid()) * " is working on the " *
            string(i) * " th loop of the CI calculation")
        
        opt_c = Opt(:AUGLAG, length(par_maxll))
        opt_c.lower_bounds = par_lb
        opt_c.upper_bounds = par_ub
        opt_c.maxeval = 5000000
        opt_c.ftol_abs = ftol_abs
        opt_c.ftol_rel = ftol_rel
        
        inequality_constraint!(opt_c, (par, grad) -> constr(par, grad), 1e-6)
        
        opt_l = NLopt.Opt(:LD_LBFGS, length(par_maxll))
        opt_l.ftol_abs = ftol_abs
        opt_l.ftol_rel = ftol_rel
        opt_c.local_optimizer = opt_l
        
        if(i % 2 == 1)
            opt_c.min_objective = (par, grad) -> f1(par, grad, Int64((i+1)/2))
        else
            opt_c.min_objective = (par, grad) -> f2(par, grad, Int64(i/2))
        end

        lb, par_95, err_95 = optimize(opt_c, par_maxll)
        mat_95CI[i, :] = par_95
        err_95CI[i] = err_95

        println("Calculation of the " * string(i) * " th loop finished")
    end

    println(err_95CI)
end

println("\nWriting estimates")
df_estimates = DataFrame()
df_estimates[!,"variant"] = Vector{Symbol}()
df_estimates[!,"date"] = Vector{Date}()

if estimate_CI
    df_estimates[!,"b1"] = Vector{Float64}()
    df_estimates[!,"b1_lb"] = Vector{Float64}()
    df_estimates[!,"b1_ub"] = Vector{Float64}()
    df_estimates[!,"b0"] = Vector{Float64}()
    df_estimates[!,"b0_lb"] = Vector{Float64}()
    df_estimates[!,"b0_ub"] = Vector{Float64}()
else
    df_estimates[!,"b1"] = Vector{Float64}()
    df_estimates[!,"b0"] = Vector{Float64}()
end

#baseline
if estimate_CI
   row_bl = vcat(baseline, t_start, fill(0.0, 6))
else
   row_bl = vcat(baseline, t_start, 0.0, 0.0)
end

push!(df_estimates, row_bl)

#subjects
if num_k > 0
    b1_params = par_maxll[1:num_k]
    b0_params = par_maxll[num_k+1 : num_k+num_subjects]

    if((length(b1_params) + length(b0_params)) != length(par_maxll))
        error("Illegal number of parameters was estimated for b1 and b0")
    end
else
    b1_params = Vector{Float64}()
    b0_params = par_maxll
end

if estimate_CI
    for j in 1:num_subjects
        k = vec_blocks[j]

        if k == 0
            b1_j = 0.0
            b1_lb = 0.0
            b1_ub = 0.0
        else
            idx_b1 = k
            b1_j = par_maxll[idx_b1]
            b1_lb = mat_95CI[2*idx_b1 - 1, idx_b1]
            b1_ub = mat_95CI[2*idx_b1, idx_b1]
        end

        idx_b0 = num_k + j
        b0_j = par_maxll[idx_b0]
        b0_lb = mat_95CI[2*idx_b0 - 1, idx_b0]
        b0_ub = mat_95CI[2*idx_b0, idx_b0]

        new_row = [subjects[j], dict_first[subjects[j]], b1_j, b1_lb, b1_ub, b0_j, b0_lb, b0_ub]
        push!(df_estimates, new_row)
    end
else
    for j in 1:num_subjects
        if vec_blocks[j] == 0
            b1_j = 0.0
        else
            b1_j = b1_params[vec_blocks[j]]
        end

        b0_j = b0_params[j]
        row = vcat(subjects[j], dict_first[subjects[j]], b1_j, b0_j)
        push!(df_estimates, row)
    end
end

if outfile_prefix == ""
    outfile_estimate = "estimates.csv"
else
    outfile_estimate = outfile_prefix * "_estimates.csv"
end

CSV.write(outfile_estimate, df_estimates)

freedom = num_subjects + num_k

n_obs = nrow(CSV.read(infile, DataFrame))
df_loglikelihood = DataFrame()
df_loglikelihood[!,"maxll"] = [-nmaxll]
df_loglikelihood[!,"num_pars"] = [freedom]

if model_sel == "AIC"
    df_loglikelihood[!,"score"] = [2*nmaxll + 2*freedom]
elseif model_sel == "BIC"
    df_loglikelihood[!,"score"] = [2*nmaxll + freedom * log(n_obs)]
end

if outfile_prefix == ""
    outfile_loglikelihood = "loglikelihood.csv"
else
    outfile_loglikelihood = outfile_prefix * "_loglikelihood.csv"
end

CSV.write(outfile_loglikelihood, df_loglikelihood)

df_blocks = DataFrame()
df_blocks[!,"variant"] = vcat(baseline, subjects)
df_blocks[!, "block"] = vcat(0, vec_blocks)

if outfile_prefix == ""
    outfile_blocks = "blocks.csv"
else
    outfile_blocks = outfile_prefix * "_blocks.csv"
end

CSV.write(outfile_blocks, df_blocks)
println("done")
