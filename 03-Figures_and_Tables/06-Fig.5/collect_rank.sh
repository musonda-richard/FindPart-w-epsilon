#!/bin/bash

output="rank_by_epsilon.csv"
echo "dataset,epsilon,rank" > "$output"

n=19
for epsilon in $(seq 0 16); do
    folder=$(printf "%02d-d%d" "$epsilon" "$epsilon")
    file="../../01-USA-epsilon-connectivity-analysis/01-lemma-enabled/$folder/rgs-BIC.csv"
    [ -f "$file" ] || continue
    num_pars=$(awk -F',' 'NR==2 {print $4; exit}' "$file")
    rank=$((num_pars - n + 2))
    echo "USA,$epsilon,$rank" >> "$output"
done

n=141
for epsilon in $(seq 0 24); do
    folder=$(printf "%02d-d%d" "$epsilon" "$epsilon")
    file="../../02-UK-epsilon-connectivity-analysis/01-lemma-enabled/$folder/rgs-BIC.csv"
    [ -f "$file" ] || continue
    num_pars=$(awk -F',' 'NR==2 {print $4; exit}' "$file")
    rank=$((num_pars - n + 2))
    echo "UK,$epsilon,$rank" >> "$output"
done

echo "Created $output"
