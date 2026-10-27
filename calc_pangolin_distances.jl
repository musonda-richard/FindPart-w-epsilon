using CSV, DataFrames
include(joinpath(@__DIR__, "lib_pangolin.jl"))

df_count_data = DataFrame(CSV.File(ARGS[1]))

vec_names = names(df_count_data)[3:end]
df_result = DataFrame(var1 = Vector{String}(),
                      var2 = Vector{String}(),
                      org1 = Vector{String}(),
                      org2 = Vector{String}(),
                      distance = Vector{Int64}())

for i in 1:(length(vec_names) - 1)
    for j in (i+1):length(vec_names)
        push!(df_result, (var1 = vec_names[i],
                         var2 = vec_names[j],
                         org1 = get_original(vec_names[i]),
                         org2 = get_original(vec_names[j]),
                         distance = pangolin_distance(vec_names[i], vec_names[j])))
    end
end
@show df_result
CSV.write("pangolin_distances.csv", df_result)
