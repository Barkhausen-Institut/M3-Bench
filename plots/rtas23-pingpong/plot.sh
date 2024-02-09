#!/bin/bash

. tools/helper.sh

rscript_crop plots/rtas23-pingpong/plot.R "$1/eval-pingpong.pdf" "$1/pingpong.dat" | tee "$1/pingpong.table"
sed --in-place -e '/.*textbf/!d' "$1/pingpong.table"
