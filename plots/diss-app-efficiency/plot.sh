#!/bin/zsh

. tools/helper.sh

Rscript plots/diss-app-efficiency/plot.R $1/eval-app-efficiency.pdf \
    $1/eval-app-efficiency.dat $1/eval-app-pes.dat
