#!/bin/zsh

. tools/helper.sh

rscript_crop plots/bi-ctxsw-micro/plot.R $1/eval-micro.pdf --clip -6 $1/eval-times.dat $1/eval-dev.dat
