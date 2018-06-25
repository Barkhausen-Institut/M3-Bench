#!/bin/zsh

. tools/helper.sh

Rscript plots/diss-app-scale-ctx/plot.R $1/eval-app-scale-ctx.pdf $1/app-scale-ctx.dat
