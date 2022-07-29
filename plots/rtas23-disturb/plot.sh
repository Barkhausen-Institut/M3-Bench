#!/bin/bash

. tools/helper.sh

rscript_crop plots/rtas23-disturb/plot.R "$1/eval-disturb.pdf" "$1/disturb.dat"
