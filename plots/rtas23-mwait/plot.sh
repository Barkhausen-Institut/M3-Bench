#!/bin/bash

. tools/helper.sh

rscript_crop plots/rtas23-mwait/plot.R "$1/eval-mwait.pdf" "$1/mwait.dat"
