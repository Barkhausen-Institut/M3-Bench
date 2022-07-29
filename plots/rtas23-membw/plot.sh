#!/bin/bash

. tools/helper.sh

rscript_crop plots/rtas23-membw/plot.R "$1/eval-membw.pdf" "$1/membw.dat"
