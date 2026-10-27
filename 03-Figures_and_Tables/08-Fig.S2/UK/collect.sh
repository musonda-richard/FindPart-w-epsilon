#!/bin/bash

output="mle_runtime_by_width_epsilon.csv"
tmp_data=$(mktemp)
tmp_output=$(mktemp)

trap 'rm -f "$tmp_data" "$tmp_output"' EXIT

for group in 01-w1 02-w2 03-w4 04-w8; do
    [ -d "$group" ] || continue
    w="${group##*-w}"

    for folder in "$group"/[0-9][0-9]-d*; do
        [ -d "$folder" ] || continue

        epsilon="${folder##*-d}"
        mle_file="$folder/mle_by_rank-BIC.csv"
        elapsed_file="$folder/elapsed.csv"

        if [ ! -f "$mle_file" ] || [ ! -f "$elapsed_file" ]; then
            echo "Incomplete: $folder - skipping" >&2
            continue
        fi

        num_mle=$(awk -F',' '
            NR==1 {
                for(i=1;i<=NF;i++) {
                    gsub(/\r/,"",$i)
                    if($i=="num_mle_calculations") c=i
                }
                next
            }
            c>0 && $c!="" {
                sum+=$c
                n++
            }
            END {
                if(n>0) printf "%.0f",sum
            }
        ' "$mle_file")

        milliseconds=$(awk -F',' '
            NR==1 {
                for(i=1;i<=NF;i++) {
                    gsub(/\r/,"",$i)
                    if($i=="milliseconds") c=i
                }
                next
            }
            NR==2 && c>0 {
                print $c
                exit
            }
        ' "$elapsed_file")

        if [ -z "$num_mle" ] || [ -z "$milliseconds" ]; then
            echo "Invalid MLE or elapsed data: $folder - skipping" >&2
            continue
        fi

        minutes=$(awk -v ms="$milliseconds" 'BEGIN {printf "%.6f",ms/60000}')

        echo "$w,$epsilon,$num_mle,$milliseconds,$minutes" >> "$tmp_data"
    done
done

n=$(wc -l < "$tmp_data" | tr -d ' ')

if [ "$n" -ne 20 ]; then
    echo "ERROR: expected 20 complete runs but found $n."
    echo "Existing $output was not changed."
    exit 1
fi

echo "w,epsilon,num_mle,milliseconds,minutes" > "$tmp_output"
sort -t',' -k1,1n -k2,2n "$tmp_data" >> "$tmp_output"

mv "$tmp_output" "$output"

echo "Created $output from $n complete runs."
