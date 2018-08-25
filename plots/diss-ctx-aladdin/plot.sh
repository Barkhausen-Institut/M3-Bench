#!/bin/bash

. tools/helper.sh

Rscript plots/diss-ctx-aladdin/plot.R $1/eval-ctx-aladdin.pdf \
    $1/stencil-file-times.dat \
    $1/md-file-times.dat \
    $1/fft-file-times.dat \
    $1/spmv-file-times.dat
