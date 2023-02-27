#!/bin/bash

. tools/helper.sh

Rscript plots/rtas23-disturb/plot.R "$1/eval-hw-0-disturb.pdf" "$1/hw-0-disturb.dat"
Rscript plots/rtas23-disturb/plot.R "$1/eval-gem5-0-disturb.pdf" "$1/gem5-0-disturb.dat"
Rscript plots/rtas23-disturb/plot.R "$1/eval-gem5-4K-disturb.pdf" "$1/gem5-4K-disturb.dat"

args=()
for bw in 4K 16K 64K 256K 1024K 4096K; do
    args=("${args[@]}" "$1/gem5-$bw-disturb.dat")
done
Rscript plots/rtas23-disturb/plot-noc-limit.R "$1/eval-gem5-all-disturb.pdf" "${args[@]}"
