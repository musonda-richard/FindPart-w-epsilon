#!/bin/bash

output="BIC_by_epsilon_USA_UK.csv"
echo "dataset,epsilon,BIC" > "$output"

for epsilon in $(seq 0 16); do
    folder=$(printf "%02d-d%d" "$epsilon" "$epsilon")
    file="../../01-USA-epsilon-connectivity-analysis/01-lemma-enabled/$folder/rgs-BIC.csv"
    [ -f "$file" ] || continue
    bic=$(awk -F',' 'NR==2 {print $5; exit}' "$file")
    echo "USA,$epsilon,$bic" >> "$output"
done

for epsilon in $(seq 0 24); do
    folder=$(printf "%02d-d%d" "$epsilon" "$epsilon")
    file="../../02-UK-epsilon-connectivity-analysis/01-lemma-enabled/$folder/rgs-BIC.csv"
    [ -f "$file" ] || continue
    bic=$(awk -F',' 'NR==2 {print $5; exit}' "$file")
    echo "UK,$epsilon,$bic" >> "$output"
done

echo "Created $output"
