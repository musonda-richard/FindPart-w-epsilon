#!/bin/bash

output="bic_by_width.csv"
tmp="${output}.tmp"

echo "w,bic" > "$tmp"
n=0

collect_one () {
    folder="$1"
    label="$2"
    file="$folder/rgs-BIC.csv"

    [ -f "$file" ] || return

    bic=$(awk -F',' 'NR==2 {print $5; exit}' "$file")

    if [ -n "$bic" ]; then
        echo "$label,$bic" >> "$tmp"
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
