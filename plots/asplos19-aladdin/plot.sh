#!/bin/bash

. tools/helper.sh

for t in file anon; do
    rscript_crop plots/asplos19-aladdin/plot-total.R $1/eval-accel-aladdin-$t.pdf --clip -5 \
        $1/stencil-$t-times.dat \
        $1/md-$t-times.dat \
        $1/fft-$t-times.dat \
        $1/spmv-$t-times.dat

    rscript_crop plots/asplos19-aladdin/plot-comp.R $1/eval-accel-aladdin-$t-comp.pdf --clip -5 \
        $1/stencil-$t-comptimes.dat $1/stencil-$t-compmax.dat \
        $1/md-$t-comptimes.dat $1/md-$t-compmax.dat \
        $1/fft-$t-comptimes.dat $1/fft-$t-compmax.dat \
        $1/spmv-$t-comptimes.dat $1/spmv-$t-compmax.dat
done
