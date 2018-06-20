#!/bin/zsh

. tools/helper.sh

rscript_crop plots/diss-app-pipe/plot.R $1/eval-app-pipe.pdf --clip -4 \
    $1/eval-app-pipe-cat-awk.dat \
    $1/eval-app-pipe-cat-wc.dat \
    $1/eval-app-pipe-grep-awk.dat \
    $1/eval-app-pipe-grep-wc.dat
