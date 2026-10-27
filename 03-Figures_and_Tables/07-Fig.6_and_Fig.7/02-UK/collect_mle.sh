#!/bin/bash

output="mle_by_width.csv"
tmp="${output}.tmp"

echo "w,num_mle" > "$tmp"
n=0

for folder in [0-9]*-w*; do
    [ -d "$folder" ] || continue
    [ -f "$folder/mle_by_rank-BIC.csv" ] || continue

    w="${folder##*-w}"

    num_mle=$(awk -F',' '
        NR>1 && $NF!="" {
            sum += $NF
            nrow++
        }
        END {
            if (nrow>0) print sum
        }
    ' "$folder/mle_by_rank-BIC.csv")

    if [ -n "$num_mle" ]; then
        echo "$w,$num_mle" >> "$tmp"
        n=$((n + 1))
    fi
done

if [ "$n" -eq 0 ]; then
    rm -f "$tmp"
    echo "No completed run folders found. Existing $output was not changed."
    exit 1
fi

sort -t',' -k1,1n "$tmp" -o "$tmp"
{
    echo "w,num_mle"
    tail -n +2 "$tmp"
} > "${tmp}.sorted"

mv "${tmp}.sorted" "$output"
rm -f "$tmp"

echo "Created $output from $n completed run(s)"
