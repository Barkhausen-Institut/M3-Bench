#!/bin/bash

. tools/helper.sh

rscript_crop plots/rtas24-sendprios/plot.R "$1/eval-sendprios.pdf" "$1/sendprios.dat"
