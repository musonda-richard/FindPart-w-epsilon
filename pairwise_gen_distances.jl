using DataFrames, CSV, Combinatorics
include("lib_pangolin.jl")
df_counts = CSV.read("count_variants.csv",DataFrame)
@show variants = names(df_counts)[3:end]

pairs = collect(combinations(variants, 2))

vec_distances = Vector{Int64}()

for i in 1:length(pairs)
    push!(vec_distances, pangolin_distance(pairs[i][1],pairs[i][2]))
end

results = DataFrame(
    variant1 = [p[1] for p in pairs],
    variant2 = [p[2] for p in pairs],
    distance = vec_distances)

CSV.write("pairwise_gen_distances.csv", results)

