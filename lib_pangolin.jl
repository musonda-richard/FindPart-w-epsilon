using CSV, DataFrames
df_alias = DataFrame(CSV.File("pangolin_alias.csv"))

function get_original(lineage::String)
    rows = filter(x -> x.lineage == lineage, df_alias)
    @assert nrow(rows) == 1
    rows.original_name[1]
end

function pangolin_distance(lineage1::String, lineage2::String)
    distance = 0 
    original_name1 = get_original(lineage1) 
    original_name2 = get_original(lineage2)
    array1 = split(original_name1, ".")
    array2 = split(original_name2, ".")

    length1 = length(array1)
    length2 = length(array2)
    num_common = 0
    for i in 1:minimum([length1,length2])
        if (array1[i] == array2[i])
            num_common = num_common + 1
            continue
        else
            break
        end
    end
    distance = (length1 - num_common) + (length2 - num_common)
    return distance
end

