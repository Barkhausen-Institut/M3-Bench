#!/bin/bash

. tools/helper.sh

rscript_crop plots/isca23-ycsb/plot.R "$1/eval-ycsb.pdf" "$1/ycsb.dat"
