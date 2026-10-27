#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: bash create_folders.sh START_WIDTH END_WIDTH"
    echo "Example: bash create_folders.sh 1 23"
    exit 1
fi

start_width=$1
end_width=$2

if ! [[ "$start_width" =~ ^[1-9][0-9]*$ ]] || ! [[ "$end_width" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: START_WIDTH and END_WIDTH must be positive integers"
    exit 1
fi

if [ "$start_width" -gt "$end_width" ]; then
    echo "Error: START_WIDTH cannot be greater than END_WIDTH"
    exit 1
fi

if [ ! -d "template" ]; then
    echo "Error: template directory not found"
    exit 1
fi

for width in $(seq "$start_width" "$end_width"); do
    folder="${width}-w${width}"

    if [ -d "$folder" ]; then
        echo "$folder already exists - skipping"
        continue
    fi

    echo "Creating $folder"
    mkdir "$folder"
    cp -a template/. "$folder"/

    awk -v width="$width" '
        /^WIDTH=/ {print "WIDTH=" width; next}
        {print}
    ' "$folder/Makefile" > "$folder/Makefile.tmp"

    mv "$folder/Makefile.tmp" "$folder/Makefile"

    echo "$folder: $(grep '^WIDTH=' "$folder/Makefile")"
done
