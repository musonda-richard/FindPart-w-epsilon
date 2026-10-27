#!/bin/bash

threads=${THREADS:-1}

run_folder () {
    folder="$1"
    expected_width="$2"

    if [ ! -d "$folder" ]; then
        echo "$folder does not exist - skipping"
        return
    fi

    if [ -f "$folder/elapsed.csv" ]; then
        echo "$folder already completed - skipping"
        return
    fi

    current_width=$(grep '^WIDTH=' "$folder/Makefile" | cut -d= -f2)

    if [ "$current_width" != "$expected_width" ]; then
        echo "$folder has WIDTH=$current_width but should have WIDTH=$expected_width - skipping"
        return
    fi

    echo "Running $folder with WIDTH=$expected_width using $threads Julia thread(s)"

    (
        cd "$folder" || exit 1
        make THREADS="$threads"
    )

    if [ $? -ne 0 ]; then
        echo "ERROR: $folder failed"
        exit 1
    fi
}

run_folder "1-w1" 1

i=2
for width in $(seq 10000 10000 200000); do
    run_folder "${i}-w${width}" "$width"
    i=$((i + 1))
done
run_folder "9999-w.infty" -1
