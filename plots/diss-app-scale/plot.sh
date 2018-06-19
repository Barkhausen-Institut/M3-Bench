#!/bin/zsh

. tools/helper.sh

for tr in tar untar find sqlite leveldb sha256sum sort; do
    rscript_crop plots/diss-app-scale/plot.R $1/eval-app-scale-$tr.pdf $1/app-scale-$tr.dat
done
