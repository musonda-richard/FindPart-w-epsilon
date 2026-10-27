vec_lines = readlines(joinpath(@__DIR__, "lineage_notes.txt"))
println("lineage,original_name")

for l in vec_lines
    if occursin('\t', string(l))
        a = split(l, '\t')
        lineage = a[1]
        if startswith(a[1],"*") || startswith(a[1], "Lineage") 
            continue
        else
            if occursin("Alias", a[2])
                b = split(a[2]," ")
                original = split(b[3], ",")[1]
            elseif occursin("alias", a[2])
                  b = split(a[2]," ")
                  original = split(b[5], ",")[1]
            #add handling of "alias"
            else
                original = a[1]
            end
        end
        println(lineage * "," * original)
    else
        @show l
        @assert false
    end
end
