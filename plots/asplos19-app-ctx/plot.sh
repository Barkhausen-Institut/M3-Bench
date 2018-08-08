#!/bin/bash

. tools/helper.sh

rscript_crop plots/asplos19-app-ctx/plot.R $1/eval-app-ctx.pdf $1/eval-app-ctx.dat
