#!/bin/bash

. tools/helper.sh

rscript_crop plots/diss-fs-ext/plot.R $1/eval-fs-ext.pdf $1/fs-a-ext.dat
