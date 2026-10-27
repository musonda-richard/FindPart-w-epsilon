include("lib_setpartition.jl")
include("RelRe_Softmax_Core.jl")

using DataFrames, CSV, SHA, Base.Threads, Dates, Clustering
using .RelReSoftmaxCore

start_time = now()

if !(length(ARGS) in (7, 8))
    @error "Usage: julia FindPart-w-epsilon.jl count_file baseline FTOL_REL width epsilon model_selection lemma_option [dbscan_option]"
    exit(1)
end

count_file = ARGS[1]
baseline = ARGS[2]
FTOL_REL = parse(Float64, ARGS[3])
width = parse(Int64, ARGS[4])
epsilon = parse(Int64, ARGS[5])
model_sel = uppercase(ARGS[6])
lemma_option = lowercase(ARGS[7])
dbscan_option = length(ARGS) == 8 ? lowercase(ARGS[8]) : "dbscan"

(width == -1 || width >= 1) || error("width must be -1 for infinity or a positive integer")
lemma_option in ["lemma", "no_lemma"] || error("lemma_option must be lemma or no_lemma")
dbscan_option in ["dbscan", "no_dbscan"] || error("dbscan_option must be dbscan or no_dbscan")

const use_lemma = lemma_option == "lemma"
const use_dbscan = dbscan_option == "dbscan"

df = CSV.read(count_file, DataFrame)
n_obs = nrow(df)

variants = names(df)[3:end]
deleteat!(variants, findfirst(isequal(baseline), variants))
insert!(variants, 1, baseline)

@show variants
println("beam width = ", width == -1 ? "∞" : string(width))
@show lemma_option
@show dbscan_option
@show epsilon

const n = length(variants)

println("running first MLE for the finest partition")
println(now())
flush(stdout)

finest_start_time = time_ns()
fit_finest = RelReSoftmaxCore.run_unconstrained_softmax(df, baseline, FTOL_REL, model_sel)
finest_elapsed = (time_ns() - finest_start_time) / 1e6

df_finest_elapsed = DataFrame(epsilon = 0, milliseconds = finest_elapsed)
CSV.write("finest_elapsed.csv", df_finest_elapsed)

score_finest = fit_finest.score
ll_finest = fit_finest.ll
num_pars_finest = fit_finest.num_pars

CSV.write("estimates.csv", fit_finest.estimates)

println("first MLE finished")
println("ll_finest = $ll_finest")
println("num_pars_finest = $num_pars_finest")
println("score_finest = $score_finest")
println("finest partition elapsed time = $finest_elapsed milliseconds")
println("Created estimates.csv")
println("Created finest_elapsed.csv")
println(now())
flush(stdout)

const SOFTMAX_DATA = RelReSoftmaxCore.prepare_softmax_data(df, baseline, fit_finest.estimates)

function load_distance_matrix(distance_file::AbstractString, variants::Vector{String})
    df_distance = CSV.read(distance_file, DataFrame)
    required_columns = [:var1, :var2, :distance]
    all(column -> column in propertynames(df_distance), required_columns) || error("$distance_file must contain var1, var2 and distance columns")

    variant_index = Dict{String,Int64}(variant => i for (i, variant) in enumerate(variants))
    distance_matrix = fill(typemax(Int64), length(variants), length(variants))

    @inbounds for i in eachindex(variants)
        distance_matrix[i, i] = 0
    end

    for row in eachrow(df_distance)
        var1 = String(row.var1)
        var2 = String(row.var2)
        i = get(variant_index, var1, 0)
        j = get(variant_index, var2, 0)

        if i != 0 && j != 0
            distance = Int64(row.distance)
            distance_matrix[i, j] = distance
            distance_matrix[j, i] = distance
        end
    end

    missing_pairs = Tuple{String,String}[]

    for i in 1:(length(variants) - 1), j in (i + 1):length(variants)
        if distance_matrix[i, j] == typemax(Int64)
            push!(missing_pairs, (variants[i], variants[j]))
        end
    end

    if !isempty(missing_pairs)
        error("Missing Pango distances for $(length(missing_pairs)) lineage pairs; first missing pair: $(first(missing_pairs))")
    end

    return distance_matrix
end

const DISTANCE_MATRIX = load_distance_matrix("pangolin_distances.csv", variants)

function run_dbscan(distance_matrix::Matrix{Int64}, epsilon::Int64)
    result = dbscan(distance_matrix, epsilon, min_neighbors = 1, min_cluster_size = 1, metric = nothing)
    cluster_id = Int64.(result.assignments)

    baseline_cluster = cluster_id[1]
    unique_clusters = unique(cluster_id)

    new_block = Dict{Int64,Int64}()
    new_block[baseline_cluster] = 0
    next_block = 1

    for cluster in unique_clusters
        if cluster != baseline_cluster
            new_block[cluster] = next_block
            next_block += 1
        end
    end

    return [new_block[cluster] for cluster in cluster_id]
end

const DBSCAN_CLUSTER = use_dbscan ? run_dbscan(DISTANCE_MATRIX, epsilon) : fill(Int64(-1), n)

if use_dbscan
    df_dbscan = DataFrame(lineage = variants, block = DBSCAN_CLUSTER)
    CSV.write("dbscan_result_epsilon$(epsilon).csv", df_dbscan)
    println("DBSCAN created $(length(unique(DBSCAN_CLUSTER))) blocks")
    println("Created dbscan_result_epsilon$(epsilon).csv")
    flush(stdout)
end

function blocks_within_epsilon(pos_s::Vector{Int64}, pos_t::Vector{Int64}, epsilon::Int64)
    if use_dbscan && DBSCAN_CLUSTER[pos_s[1]] != DBSCAN_CLUSTER[pos_t[1]]
        return false
    end

    @inbounds for i in pos_s, j in pos_t
        if DISTANCE_MATRIX[i, j] <= epsilon
            return true
        end
    end

    return false
end

function aggregations_of_blocks_within(vec_block::Vector{Int64}, epsilon::Int64)
    @assert is_restricted_growth(vec_block)

    result = Vector{Vector{Int64}}()
    m = maximum(vec_block)
    pairs = collect(combinations(0:m, 2))

    for pair in pairs
        s = pair[1]
        t = pair[2]

        pos_s = findall(x -> x == s, vec_block)
        pos_t = findall(x -> x == t, vec_block)

        blocks_within_epsilon(pos_s, pos_t, epsilon) || continue

        aggregation = Vector{Int64}(vec_block)

        for i in 0:m
            if i == s
                continue
            elseif i == t
                index = findall(x -> x == t, aggregation)
                aggregation[index] .= s
            elseif i > t
                index = findall(x -> x == i, aggregation)
                aggregation[index] .= i - 1
            end
        end

        push!(result, aggregation)
    end

    return result
end

function separate_rgs(vec_rgs::Vector{Vector{Int64}})
    num = length(vec_rgs)

    println("separating $num rgs")
    println(now())
    flush(stdout)

    lock = Threads.SpinLock()

    Threads.@threads :greedy for i in 1:num
        rgs = vec_rgs[i]
        tid = Threads.threadid()

        println("$(now()) Index i=$i was assigned to thread $tid")
        flush(stdout)

        RelRe_start_time = time()
        fit = RelReSoftmaxCore.run_relre_softmax(SOFTMAX_DATA, rgs, FTOL_REL, model_sel)
        RelRe_run_time = time() - RelRe_start_time

        rgs_str = join(rgs, "-")
        ll = fit.ll
        num_pars = fit.num_pars
        score = fit.score

        Base.Threads.lock(lock) do
            push!(df_RelRe_time_taken, (RGS = rgs_str, TimeTaken = RelRe_run_time))
            println("$(now()) Calculation for i=$i was done by thread $tid with status $(fit.status)")
            flush(stdout)
        end

        if model_sel == "AIC"
            lb_agg_score = score - 2 * maximum(rgs)
        else
            lb_agg_score = score - maximum(rgs) * log(n_obs)
        end

        Base.Threads.lock(lock) do
            has_chance = true

            if use_lemma && lb_agg_score > score_min
                push!(vec_rgs_no_chance, rgs)
                has_chance = false
            end

            if has_chance
                push!(best_rgs_at_rank, (score, copy(rgs)))
                sort!(best_rgs_at_rank, by = x -> x[1])

                if width != -1 && length(best_rgs_at_rank) > width
                    resize!(best_rgs_at_rank, width)
                end
            end

            if score < score_min
                global score_min = score
            end

            push!(df_score, (rgs_str, bytes2hex(sha1(rgs_str)), ll, num_pars, score, lb_agg_score, has_chance), promote = true)
        end
    end
end

function aggregations_survived()
    vec_survived = Vector{Vector{Int64}}()
    result = Vector{Vector{Int64}}()

    for (_, rgs) in best_rgs_at_rank
        append!(result, aggregations_of_blocks_within(rgs, epsilon))
    end

    result = unique(result)

    if !use_lemma
        return result
    end

    for j in 1:length(result)
        chance = true

        for k in 1:length(vec_rgs_no_chance)
            if is_an_aggregation_of(result[j], vec_rgs_no_chance[k])
                chance = false
                break
            end
        end

        if chance
            push!(vec_survived, result[j])
        end
    end

    return unique(vec_survived)
end

vec_rgs_no_chance = Vector{Vector{Int64}}()
best_rgs_at_rank = Vector{Tuple{Float64,Vector{Int64}}}()

df_RelRe_time_taken = DataFrame(RGS = Vector{String}(), TimeTaken = Vector{Float64}())
df_score = DataFrame(rgs = Vector{String}(), sha1 = Vector{String}(), ll = Vector{Float64}(), num_pars = Vector{Int64}(), score = Vector{Float64}(), lb_agg_score = Vector{Float64}(), has_chance = Vector{Bool}())

df_mle_by_rank = DataFrame(
    epsilon = fill(epsilon, n),
    level = collect(1:n),
    rank = collect(n:-1:1),
    num_mle_calculations = zeros(Int64, n)
)

println("reading level 1")
flush(stdout)

rgs_finest = collect(0:n-1)
has_chance = true

if model_sel == "AIC"
    lb_agg_score_finest = score_finest - 2 * maximum(rgs_finest)
else
    lb_agg_score_finest = score_finest - maximum(rgs_finest) * log(n_obs)
end

score_min = score_finest

push!(df_score, (
    join(rgs_finest, "-"),
    bytes2hex(sha1(join(rgs_finest, "-"))),
    ll_finest,
    num_pars_finest,
    score_finest,
    lb_agg_score_finest,
    has_chance
), promote = true)

df_mle_by_rank[1, :num_mle_calculations] = 1

for level in 2:n
    println("\nanalysing level $level")
    println(now())
    flush(stdout)

    if level == 2
        println("creating aggregations")
        println(now())
        flush(stdout)
        global vec_rgs = aggregations_of_blocks_within(rgs_finest, epsilon)
    else
        println("creating aggregations")
        println(now())
        flush(stdout)
        global vec_rgs = aggregations_survived()
    end

    println("$(length(vec_rgs)) RGSs will be analysed")
    println(now())
    flush(stdout)

    df_mle_by_rank[level, :num_mle_calculations] = length(vec_rgs)

    if isempty(vec_rgs)
        println("no rgs to analyse")
        flush(stdout)
        break
    end

    global best_rgs_at_rank = Vector{Tuple{Float64,Vector{Int64}}}()

    separate_rgs(vec_rgs)

    if width == -1
        println("beam width = ∞; retained all $(length(best_rgs_at_rank)) surviving partition(s)")
    else
        println("beam retained $(length(best_rgs_at_rank)) partition(s) with maximum width $width")
    end

    println(now())
    flush(stdout)
end

sort!(df_score, :score)
CSV.write("rgs-score.csv", df_score)

df_no_chance = DataFrame(rgs = vec_rgs_no_chance)
df_no_chance.rgs = join.(df_no_chance.rgs, "-")
df_no_chance.sha1 = [bytes2hex(sha1(rg)) for rg in df_no_chance.rgs]

CSV.write("rgs_no_chance.csv", df_no_chance)
CSV.write("mle_by_rank-$(model_sel).csv", df_mle_by_rank)

println("csv files were created")
println(now())
flush(stdout)

elapsed = Dates.value(now() - start_time)
df_elapsed = DataFrame(epsilon = epsilon, milliseconds = elapsed)

CSV.write("elapsed.csv", df_elapsed)
CSV.write("RelRe_time_taken.csv", df_RelRe_time_taken)
