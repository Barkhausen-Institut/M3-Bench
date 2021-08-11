#!/bin/sh

. tools/helper.sh

rscript_crop plots/asplos22-fs/plot.R $1/eval-fs.pdf $1/fs-tputs.dat $1/fs-stddev.dat
