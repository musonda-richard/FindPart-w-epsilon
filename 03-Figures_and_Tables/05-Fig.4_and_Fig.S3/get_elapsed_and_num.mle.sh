#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: bash get_elapsed_and_num.mle.sh COUNTRY"
    echo "Example: bash get_elapsed_and_num.mle.sh USA"
    echo "Example: bash get_elapsed_and_num.mle.sh UK"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

country=$1

case "$country" in
    USA)
        outdir="01-elapsed_num.mle-USA"
        analysis_root="../../01-USA-epsilon-connectivity-analysis"
        ;;
    UK)
        outdir="02-elapsed_num.mle-UK"
        analysis_root="../../02-UK-epsilon-connectivity-analysis"
        ;;
    *)
        echo "COUNTRY must be USA or UK"
        exit 1
        ;;
esac

mkdir -p "$outdir"

echo "version,epsilon,milliseconds" > "$outdir/elapsed.csv"

for version in lemma no_lemma; do
    if [ "$version" = "lemma" ]; then
        base="$analysis_root/01-lemma-enabled"
    else
        base="$analysis_root/02-lemma-disabled"
    fi

    for f in "$base"/*-d*/elapsed.csv; do
        [ -f "$f" ] || continue
        epsilon=$(awk -F',' 'NR==2 {print $1}' "$f")
        milliseconds=$(awk -F',' 'NR==2 {print $2}' "$f")
        [ -n "$epsilon" ] || continue
        [ -n "$milliseconds" ] || continue
        echo "$version,$epsilon,$milliseconds" >> "$outdir/elapsed.csv"
    done
done

echo "version,epsilon,num_mle" > "$outdir/num_mle.csv"

for version in lemma no_lemma; do
    if [ "$version" = "lemma" ]; then
        base="$analysis_root/01-lemma-enabled"
    else
        base="$analysis_root/02-lemma-disabled"
    fi

    for f in "$base"/*-d*/mle_by_rank-BIC.csv; do
        [ -f "$f" ] || continue
        epsilon=$(awk -F',' 'NR==2 {print $1}' "$f")
        num_mle=$(awk -F',' 'NR>1 {sum += $4} END {print sum + 0}' "$f")
        [ -n "$epsilon" ] || continue
        echo "$version,$epsilon,$num_mle" >> "$outdir/num_mle.csv"
    done
done

(head -n 1 "$outdir/elapsed.csv" && tail -n +2 "$outdir/elapsed.csv" | sort -t',' -k1,1 -k2,2n) > "$outdir/elapsed.tmp"
mv "$outdir/elapsed.tmp" "$outdir/elapsed.csv"

(head -n 1 "$outdir/num_mle.csv" && tail -n +2 "$outdir/num_mle.csv" | sort -t',' -k1,1 -k2,2n) > "$outdir/num_mle.tmp"
mv "$outdir/num_mle.tmp" "$outdir/num_mle.csv"

echo "Created $outdir/elapsed.csv and $outdir/num_mle.csv"
