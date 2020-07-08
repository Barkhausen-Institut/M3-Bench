#!/bin/bash

. tools/helper.sh

rscript_crop plots/bi-ctxsw-shared/plot.R $1/eval-app-ctx.pdf $1/eval-app-ctx.dat
