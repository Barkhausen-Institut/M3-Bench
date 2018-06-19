#!/bin/zsh

. tools/helper.sh

rscript_crop plots/diss-pipe-scale/plot.R $1/eval-pipe-scale.pdf $1/pipe-scale.dat
