#!/bin/sh

. tools/helper.sh

rscript_crop plots/asplos22-micro/plot.R $1/eval-micro.pdf $1/micro-times.dat $1/micro-stddev.dat
