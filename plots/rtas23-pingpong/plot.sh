#!/bin/bash

. tools/helper.sh

rscript_crop plots/rtas23-pingpong/plot.R "$1/eval-pingpong.pdf" "$1/pingpong.dat"
