#!/bin/bash

. tools/helper.sh

rscript_crop plots/isca23-mem/plot.R "$1/eval-mem.pdf" "$1/mem.dat"
