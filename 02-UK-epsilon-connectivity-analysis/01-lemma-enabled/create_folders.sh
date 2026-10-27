#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Usage: bash create_folders.sh MAX_EPSILON"
    exit 1
fi

max_epsilon=$1

if ! [[ "$max_epsilon" =~ ^[0-9]+$ ]]; then
    echo "Error: MAX_EPSILON must be a non-negative integer"
    exit 1
fi

for epsilon in $(seq 0 "$max_epsilon"); do
    folder=$(printf "%02d-d%d" "$epsilon" "$epsilon")
    mkdir -p "$folder"
    cp template/Makefile "$folder/Makefile"
done
