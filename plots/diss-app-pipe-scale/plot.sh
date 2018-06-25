#!/bin/zsh

. tools/helper.sh

for m in 0 1; do
    Rscript plots/diss-app-pipe-scale/plot.R $1/eval-pipe-scale-$m.pdf $1/pipe-scale-$m.dat $m
done
