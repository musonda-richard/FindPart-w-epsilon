#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: bash run_folders.sh START_WIDTH END_WIDTH"
    echo "Example: bash run_folders.sh 1 23"
    echo "Optional: THREADS=8 bash run_folders.sh 1 23"
    exit 1
fi

start_width=$1
end_width=$2
threads=${THREADS:-1}

if ! [[ "$start_width" =~ ^[1-9][0-9]*$ ]] || ! [[ "$end_width" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: START_WIDTH and END_WIDTH must be positive integers"
    exit 1
fi

if [ "$start_width" -gt "$end_width" ]; then
    echo "Error: START_WIDTH cannot be greater than END_WIDTH"
    exit 1
fi

for width in $(seq "$start_width" "$end_width"); do
    folder="${width}-w${width}"

    if [ ! -d "$folder" ]; then
        echo "$folder does not exist - skipping"
        continue
    fi

    if [ -f "$folder/elapsed.csv" ]; then
        echo "$folder already completed - skipping"
        continue
    fi

    current_width=$(grep '^WIDTH=' "$folder/Makefile" | cut -d= -f2)

    if [ "$current_width" != "$width" ]; then
        echo "$folder has WIDTH=$current_width but should have WIDTH=$width - skipping"
        continue
    fi

    echo "Running $folder with WIDTH=$width using $threads Julia thread(s)"

    (
        cd "$folder" || exit 1
        make THREADS="$threads"
    )

    if [ $? -ne 0 ]; then
        echo "ERROR: $folder failed"
        exit 1
    fi
done
