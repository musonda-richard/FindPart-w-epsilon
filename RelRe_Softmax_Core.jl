module RelReSoftmaxCore

using Dates, DataFrames, Distributions, NLopt, Statistics

export SoftmaxData
export prepare_softmax_data
export run_unconstrained_softmax
export run_relre_softmax

struct SoftmaxData
    dates_from::Vector{Date}
    mat_obs::Matrix{Int64}
    t_start::Date
    t_end::Date
    subjects::Vector{Symbol}
    initial_b1::Vector{Float64}
    initial_b0::Vector{Float64}
    n_obs::Int64
end

function log_softmax_core(x)
    maximum_x = maximum(x)
    return x .- maximum_x .- log(sum(exp.(x .- maximum_x)))
end

function run_unconstrained_softmax(df_count::DataFrame, baseline_name::AbstractString, ftol_rel::Real, model_selection::AbstractString; ftol_abs::Real = 0.0, maxeval::Integer = 5_000_000)
    baseline = Symbol(baseline_name)
    variant_names = propertynames(df_count)[3:end]

    if !(baseline in variant_names)
        error("Baseline lineage $baseline cannot be found in count data")
    end

    subjects = filter(x -> x != baseline, variant_names)
    num_subjects = length(subjects)

    dates_from = Date.(df_count.date_from)
    t_start = minimum(df_count.date_from)
    t_end = maximum(df_count.date_till)
    observation_columns = vcat(subjects, baseline)
    mat_obs = Int64.(Matrix(df_count[:, observation_columns]))
    n_obs = nrow(df_count)

    vec_b1_start = zeros(Float64, num_subjects)
    vec_b0_start = zeros(Float64, num_subjects)

    vec_b1_lb = fill(-30.0, num_subjects)
    vec_b1_ub = fill(30.0, num_subjects)
    vec_b0_lb = fill(-30.0, num_subjects)
    vec_b0_ub = fill(30.0, num_subjects)

    par_start = vcat(vec_b1_start, vec_b0_start)
    par_lb = vcat(vec_b1_lb, vec_b0_lb)
    par_ub = vcat(vec_b1_ub, vec_b0_ub)

    duration = Dates.value(t_end - t_start) + 1

    function model_q(vec_b1::AbstractVector{<:Real}, vec_b0::AbstractVector{<:Real})
        mat_q = Matrix{Float64}(undef, duration, num_subjects + 1)

        for day_t in 1:duration
            vec_x = vcat(vec_b0 .+ vec_b1 .* (day_t - 1), 0.0)
            mat_q[day_t, :] .= exp.(log_softmax_core(vec_x))
        end

        return mat_q
    end

    function objective(par::Vector{Float64}, grad::Vector{Float64})
        vec_b1 = @view par[1:num_subjects]
        vec_b0 = @view par[(num_subjects + 1):(2 * num_subjects)]
        q = model_q(vec_b1, vec_b0)
        calculate_gradient = !isempty(grad)

        if calculate_gradient
            fill!(grad, 0.0)
        end

        sumll = 0.0

        for i in eachindex(dates_from)
            obs = @view mat_obs[i, :]
            total_observed = sum(obs)
            total_observed == 0 && continue

            t_idx = Dates.value(dates_from[i] - t_start) + 1
            probs = vec(q[t_idx, 1:(num_subjects + 1)])
            probs ./= sum(probs)
            sumll += logpdf(Multinomial(total_observed, probs), obs)

            if calculate_gradient
                time_value = t_idx - 1

                @inbounds for l in 1:num_subjects
                    difference = obs[l] - total_observed * probs[l]
                    grad[num_subjects + l] -= difference
                    grad[l] -= difference * time_value
                end
            end
        end

        if !isfinite(sumll)
            calculate_gradient && fill!(grad, 0.0)
            return floatmax(Float64)
        end

        return -sumll
    end

    opt = Opt(:LD_LBFGS, length(par_start))
    opt.min_objective = objective
    opt.lower_bounds = par_lb
    opt.upper_bounds = par_ub
    opt.ftol_abs = Float64(ftol_abs)
    opt.ftol_rel = Float64(ftol_rel)
    opt.maxeval = Int64(maxeval)

    negative_maxll, par_maxll, status = optimize(opt, par_start)

    maxll = -negative_maxll
    num_pars = 2 * num_subjects
    criterion = uppercase(model_selection)

    if criterion == "AIC"
        score = 2.0 * negative_maxll + 2.0 * num_pars
    elseif criterion == "BIC"
        score = 2.0 * negative_maxll + num_pars * log(n_obs)
    else
        error("model_selection must be AIC or BIC, not $model_selection")
    end

    df_estimates = DataFrame(variant = Vector{Symbol}(), date = Vector{Date}(), b1 = Vector{Float64}(), b0 = Vector{Float64}())
    push!(df_estimates, (baseline, t_start, 0.0, 0.0))

    for j in 1:num_subjects
        push!(df_estimates, (subjects[j], t_start, par_maxll[j], par_maxll[num_subjects + j]))
    end

    return (ll = maxll, num_pars = num_pars, score = score, status = status, parameters = par_maxll, estimates = df_estimates)
end

function prepare_softmax_data(df_count::DataFrame, baseline_name::AbstractString, df_initial::DataFrame)
    baseline = Symbol(baseline_name)
    variant_names = propertynames(df_count)[3:end]

    if !(baseline in variant_names)
        error("Baseline lineage $baseline cannot be found in count data")
    end

    subjects = filter(x -> x != baseline, variant_names)
    num_subjects = length(subjects)

    dates_from = Date.(df_count.date_from)
    t_start = minimum(df_count.date_from)
    t_end = maximum(df_count.date_till)
    observation_columns = vcat(subjects, baseline)
    mat_obs = Int64.(Matrix(df_count[:, observation_columns]))

    estimate_index = Dict{Symbol,Int64}()

    for i in 1:nrow(df_initial)
        estimate_index[Symbol(df_initial.variant[i])] = i
    end

    initial_b1 = Vector{Float64}(undef, num_subjects)
    initial_b0 = Vector{Float64}(undef, num_subjects)

    for j in 1:num_subjects
        subject = subjects[j]

        if !haskey(estimate_index, subject)
            error("Initial estimates for $subject cannot be found")
        end

        row_index = estimate_index[subject]
        initial_b1[j] = Float64(df_initial.b1[row_index])
        initial_b0[j] = Float64(df_initial.b0[row_index])
    end

    return SoftmaxData(dates_from, mat_obs, t_start, t_end, subjects, initial_b1, initial_b0, Int64(nrow(df_count)))
end

function is_restricted_growth_core(rgs::AbstractVector{<:Integer})
    isempty(rgs) && return false
    rgs[1] == 0 || return false

    maximum_seen = 0

    @inbounds for i in 2:length(rgs)
        label = rgs[i]

        if label < 0 || label > maximum_seen + 1
            return false
        end

        if label > maximum_seen
            maximum_seen = label
        end
    end

    return true
end

function run_relre_softmax(data::SoftmaxData, rgs::AbstractVector{<:Integer}, ftol_rel::Real, model_selection::AbstractString; ftol_abs::Real = 0.0, maxeval::Integer = 5_000_000)
    num_subjects = length(data.subjects)

    if length(rgs) != num_subjects + 1
        error("RGS length $(length(rgs)) does not match $(num_subjects + 1) variants")
    end

    if !is_restricted_growth_core(rgs)
        error("The supplied blocks vector is not a restricted growth string")
    end

    vec_blocks = Int64.(rgs[2:end])
    num_k = maximum(vec_blocks; init = 0)

    vec_b1_start = zeros(Float64, num_k)

    for k in 1:num_k
        indices = findall(x -> x == k, vec_blocks)

        if isempty(indices)
            error("Block label $k is missing from the RGS")
        end

        vec_b1_start[k] = mean(data.initial_b1[indices])
    end

    vec_b0_start = copy(data.initial_b0)

    vec_b1_lb = fill(-30.0, num_k)
    vec_b1_ub = fill(30.0, num_k)
    vec_b0_lb = fill(-30.0, num_subjects)
    vec_b0_ub = fill(30.0, num_subjects)

    par_start = vcat(vec_b1_start, vec_b0_start)
    par_lb = vcat(vec_b1_lb, vec_b0_lb)
    par_ub = vcat(vec_b1_ub, vec_b0_ub)

    duration = Dates.value(data.t_end - data.t_start) + 1

    function model_q(vec_b1::AbstractVector{<:Real}, vec_b0::AbstractVector{<:Real})
        mat_q = Matrix{Float64}(undef, duration, num_subjects + 1)

        for day_t in 1:duration
            vec_x = vcat(vec_b0 .+ vec_b1 .* (day_t - 1), 0.0)
            mat_q[day_t, :] .= exp.(log_softmax_core(vec_x))
        end

        return mat_q
    end

    function expand_b1(vec_b1_tmp::AbstractVector{<:Real})
        vec_b1 = Vector{Float64}(undef, num_subjects)

        @inbounds for l in 1:num_subjects
            block = vec_blocks[l]
            vec_b1[l] = block == 0 ? 0.0 : vec_b1_tmp[block]
        end

        return vec_b1
    end

    function objective(par::Vector{Float64}, grad::Vector{Float64})
        vec_b1_tmp = @view par[1:num_k]
        vec_b0 = @view par[(num_k + 1):(num_k + num_subjects)]
        vec_b1 = expand_b1(vec_b1_tmp)
        q = model_q(vec_b1, vec_b0)
        calculate_gradient = !isempty(grad)

        if calculate_gradient
            fill!(grad, 0.0)
        end

        sumll = 0.0

        for i in eachindex(data.dates_from)
            obs = @view data.mat_obs[i, :]
            total_observed = sum(obs)
            total_observed == 0 && continue

            t_idx = Dates.value(data.dates_from[i] - data.t_start) + 1
            probs = vec(q[t_idx, 1:(num_subjects + 1)])
            probs ./= sum(probs)
            sumll += logpdf(Multinomial(total_observed, probs), obs)

            if calculate_gradient
                time_value = t_idx - 1

                @inbounds for l in 1:num_subjects
                    difference = obs[l] - total_observed * probs[l]
                    grad[num_k + l] -= difference
                    block = vec_blocks[l]

                    if block != 0
                        grad[block] -= difference * time_value
                    end
                end
            end
        end

        if !isfinite(sumll)
            calculate_gradient && fill!(grad, 0.0)
            return floatmax(Float64)
        end

        return -sumll
    end

    opt = Opt(:LD_LBFGS, length(par_start))
    opt.min_objective = objective
    opt.lower_bounds = par_lb
    opt.upper_bounds = par_ub
    opt.ftol_abs = Float64(ftol_abs)
    opt.ftol_rel = Float64(ftol_rel)
    opt.maxeval = Int64(maxeval)

    negative_maxll, par_maxll, status = optimize(opt, par_start)

    maxll = -negative_maxll
    num_pars = num_subjects + num_k
    criterion = uppercase(model_selection)

    if criterion == "AIC"
        score = 2.0 * negative_maxll + 2.0 * num_pars
    elseif criterion == "BIC"
        score = 2.0 * negative_maxll + num_pars * log(data.n_obs)
    else
        error("model_selection must be AIC or BIC, not $model_selection")
    end

    return (ll = maxll, num_pars = num_pars, score = score, status = status, parameters = par_maxll)
end

end
