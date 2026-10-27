#!/bin/bash

if [ ! -d "template" ]; then
    echo "Error: template directory not found"
    exit 1
fi

epsilons=(1 2 4 8 16)

i=1
for epsilon in "${epsilons[@]}"; do
    folder=$(printf "%02d-d%d" "$i" "$epsilon")

    if [ -d "$folder" ]; then
        echo "$folder already exists - skipping"
        i=$((i + 1))
        continue
    fi

    echo "Creating $folder"
    mkdir "$folder"
    cp -a template/. "$folder"/

    awk -v epsilon="$epsilon" '
        /^EPSILON=/ {print "EPSILON=" epsilon; next}
        {print}
    ' "$folder/Makefile" > "$folder/Makefile.tmp"

    mv "$folder/Makefile.tmp" "$folder/Makefile"
    echo "$folder: $(grep '^EPSILON=' "$folder/Makefile")"

    i=$((i + 1))
done
