#!/bin/bash

. tools/helper.sh

rscript_crop plots/isca23-ipc/plot.R "$1/eval-ipc.pdf" "$1/ipc.dat"
