#!/bin/bash
set -e

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: bash run_folders.sh MAX_EPSILON [THREADS]"
    exit 1
fi

max_epsilon=$1
threads=${2:-1}

if ! [[ "$max_epsilon" =~ ^[0-9]+$ ]]; then
    echo "Error: MAX_EPSILON must be a non-negative integer"
    exit 1
fi

if ! [[ "$threads" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: THREADS must be a positive integer"
    exit 1
fi

for epsilon in $(seq 0 "$max_epsilon"); do
    folder=$(printf "%02d-d%d" "$epsilon" "$epsilon")

    if [ ! -d "$folder" ]; then
        echo "$folder does not exist - skipping"
        continue
    fi

    echo "Running $folder with EPSILON=$epsilon THREADS=$threads"
    make -C "$folder" EPSILON="$epsilon" THREADS="$threads"
done
