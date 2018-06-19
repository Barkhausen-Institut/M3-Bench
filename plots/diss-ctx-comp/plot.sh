#!/bin/zsh

. tools/helper.sh

for t in c; do
    rscript_crop plots/diss-ctx-comp/plot.R $1/eval-ctx-comp-$t.pdf $1/comp-ctx-$t.dat
done
