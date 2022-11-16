#!/bin/bash

. tools/helper.sh

rscript_crop plots/isca23-facever/plot.R "$1/eval-facever.pdf" "$1/facever.dat"
