#!/bin/bash

. tools/helper.sh

rscript_crop plots/hcds24-distaccel/plot.R "$1/eval-distaccel.pdf" "$1/distaccel.dat"
