#!/bin/zsh

Rscript plots/diss-imgproc/plot-time.R $1/eval-imgproc-times.pdf \
    $1/imgproc-1-times.dat \
    $1/imgproc-2-times.dat \
    $1/imgproc-3-times.dat \
    $1/imgproc-4-times.dat

Rscript plots/diss-imgproc/plot-util.R $1/eval-imgproc-util.pdf \
    $1/imgproc-1-util.dat \
    $1/imgproc-2-util.dat \
    $1/imgproc-3-util.dat \
    $1/imgproc-4-util.dat

Rscript plots/diss-imgproc/plot-ctxsw.R $1/eval-imgproc-ctxsw.pdf \
    $1/imgproc-1-ctxsw.dat \
    $1/imgproc-2-ctxsw.dat \
    $1/imgproc-3-ctxsw.dat \
    $1/imgproc-4-ctxsw.dat
