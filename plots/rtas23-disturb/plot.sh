#!/bin/bash

. tools/helper.sh

Rscript plots/rtas23-disturb/plot.R "$1/eval-hw-0-disturb.pdf" "$1/hw-0-disturb.dat"
Rscript plots/rtas23-disturb/plot.R "$1/eval-gem5-0-disturb.pdf" "$1/gem5-0-disturb.dat"
Rscript plots/rtas23-disturb/plot.R "$1/eval-gem5-8K-disturb.pdf" "$1/gem5-8K-disturb.dat"

args=()
for bw in 8K 32K 128K 512K 2048K; do
    args=("${args[@]}" "$1/gem5-$bw-disturb.dat")
done
Rscript plots/rtas23-disturb/plot-noc-limit.R "$1/eval-gem5-all-disturb.pdf" "${args[@]}"
