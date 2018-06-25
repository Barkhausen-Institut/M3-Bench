#!/bin/bash

. tools/helper.sh

rscript_crop plots/diss-app-ctx/plot.R $1/eval-app-ctx.pdf $1/eval-app-ctx.dat
