#!/bin/bash

M3_GEM5_OUT=${M3_GEM5_OUT:-run}

if [ $# -ne 5 ]; then
    echo "Usage: $0 <name> <benchs> <posts> <plots> <jobs>" 1>&2
    exit 1
fi

name=$1
benchs=$2
posts=$3
plots=$4

mkdir -p results
res=$(readlink -f "results/$name")
mkdir -p "$res"

# increase number of file descriptors
ulimit -n 16384

for b in $benchs; do
    "./benchs/$b.sh" "$res" "$5"
done

for p in $posts; do
    "./plots/$p/post.sh" "$res"
done

for p in $plots; do
    "./plots/$p/plot.sh" "$res"
done
