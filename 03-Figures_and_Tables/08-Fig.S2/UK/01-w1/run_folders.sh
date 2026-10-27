#!/bin/bash

threads=${THREADS:-1}
epsilons=(1 2 4 8 16)

i=1
for epsilon in "${epsilons[@]}"; do
    folder=$(printf "%02d-d%d" "$i" "$epsilon")

    if [ ! -d "$folder" ]; then
        echo "$folder does not exist - skipping"
        i=$((i + 1))
        continue
    fi

    if [ -f "$folder/elapsed.csv" ]; then
        echo "$folder already completed - skipping"
        i=$((i + 1))
        continue
    fi

    current_epsilon=$(grep '^EPSILON=' "$folder/Makefile" | cut -d= -f2)

    if [ "$current_epsilon" != "$epsilon" ]; then
        echo "$folder has EPSILON=$current_epsilon but should have EPSILON=$epsilon - skipping"
        i=$((i + 1))
        continue
    fi

    echo "Running $folder with EPSILON=$epsilon using $threads Julia thread(s)"

    (
        cd "$folder" || exit 1
        make THREADS="$threads"
    )

    if [ $? -ne 0 ]; then
        echo "ERROR: $folder failed"
        exit 1
    fi

    i=$((i + 1))
done
