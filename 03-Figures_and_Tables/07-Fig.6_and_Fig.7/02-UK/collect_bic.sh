#!/bin/bash

output="bic_by_width.csv"
tmp="${output}.tmp"

echo "w,bic,milliseconds" > "$tmp"
n=0

for w in $(seq 1 23); do
    folder="${w}-w${w}"

    [ -f "$folder/rgs-BIC.csv" ] || continue
    [ -f "$folder/elapsed.csv" ] || continue

    bic=$(awk -F',' 'NR==2 {print $5; exit}' "$folder/rgs-BIC.csv")
    milliseconds=$(awk -F',' 'NR==2 {print $NF; exit}' "$folder/elapsed.csv")

    echo "$w,$bic,$milliseconds" >> "$tmp"
    n=$((n + 1))
done

if [ "$n" -eq 0 ]; then
    rm -f "$tmp"
    echo "No completed run folders found. Existing $output was not changed."
    exit 1
fi

mv "$tmp" "$output"
echo "Created $output from $n completed run(s)"
