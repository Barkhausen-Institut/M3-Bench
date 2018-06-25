#!/bin/bash

. tools/helper.sh

rscript_crop plots/diss-app-pipe-ctx/plot.R $1/eval-app-pipe-ctx.pdf $1/eval-app-pipe-ctx.dat
