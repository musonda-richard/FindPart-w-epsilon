#!/bin/bash

if [ ! -d "template" ]; then
    echo "Error: template directory not found"
    exit 1
fi

i=1

create_folder () {
    width="$1"
    folder="$2"

    if [ -d "$folder" ]; then
        echo "$folder already exists - skipping"
        return
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
}

create_folder 1 "1-w1"

i=2
for width in $(seq 10000 10000 200000); do
    create_folder "$width" "${i}-w${width}"
    i=$((i + 1))
done
create_folder -1 "9999-w.infty"
