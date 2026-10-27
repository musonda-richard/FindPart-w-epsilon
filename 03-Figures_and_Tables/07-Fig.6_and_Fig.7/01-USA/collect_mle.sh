#!/bin/bash

output="mle_by_width.csv"
tmp="${output}.tmp"

echo "w,num_mle" > "$tmp"
n=0

collect_one () {
    folder="$1"
    label="$2"
    file="$folder/mle_by_rank-BIC.csv"

    [ -f "$file" ] || return

    num_mle=$(awk -F',' '
        NR>1 && $NF!="" {
            sum += $NF
            nrow++
        }
        END {
            if (nrow>0) print sum
        }
    ' "$file")

    if [ -n "$num_mle" ]; then
        echo "$label,$num_mle" >> "$tmp"
        n=$((n + 1))
    fi
}

collect_one "1-w1" 1

i=2
for width in $(seq 10000 10000 200000); do
    collect_one "${i}-w${width}" "$width"
    i=$((i + 1))
done

collect_one "9999-w.infty" Inf

if [ "$n" -eq 0 ]; then
    rm -f "$tmp"
    echo "No completed run folders found. Existing $output was not changed."
    exit 1
fi

mv "$tmp" "$output"
echo "Created $output from $n completed run(s)"
