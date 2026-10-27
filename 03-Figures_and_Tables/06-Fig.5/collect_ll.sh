#!/bin/bash
output="loglik_by_epsilon.csv"
echo "dataset,epsilon,loglik" > "$output"
collect_ll () {
    dataset=$1
    base_dir=$2
    max_epsilon=$3
    for e in $(seq 0 "$max_epsilon"); do
        folder=$(printf "%02d-d%d" "$e" "$e")
        file="$base_dir/$folder/rgs-BIC.csv"
        [ -f "$file" ] || { echo "Missing: $file"; continue; }
        ll=$(awk -F',' 'NR==2 {print $3; exit}' "$file")
        echo "$dataset,$e,$ll" >> "$output"
    done
}
collect_ll "USA" "../../01-USA-epsilon-connectivity-analysis/01-lemma-enabled" 16
collect_ll "UK" "../../02-UK-epsilon-connectivity-analysis/01-lemma-enabled" 24
echo "Created $output"
