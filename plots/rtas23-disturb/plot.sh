#!/bin/bash

. tools/helper.sh

Rscript plots/rtas23-disturb/plot.R "$1/eval-hw-0-disturb.pdf" "$1/hw-0-disturb.dat"
for bw in 0 4K 8K 16K 32K 64K 128K 256K 512K 1024K; do
    Rscript plots/rtas23-disturb/plot.R "$1/eval-gem5-$bw-disturb.pdf" "$1/gem5-$bw-disturb.dat"
done
