#!/bin/bash

. tools/helper.sh

rscript_crop plots/atc19-ctx-susp/plot.R $1/eval-ctx-susp.pdf \
    $1/ctx-susp-times.dat $1/ctx-susp-stddev.dat
