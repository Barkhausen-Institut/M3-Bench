#!/bin/zsh

. tools/helper.sh

rscript_crop plots/diss-ctx-pipe/plot.R $1/eval-ctx-pipe.pdf --clip -4 \
    $1/ctx-pipe-rand-wc.dat $1/ctx-pipe-rand-wc-stddev.dat \
    $1/ctx-pipe-rand-sink.dat $1/ctx-pipe-rand-sink-stddev.dat \
    $1/ctx-pipe-cat-wc.dat $1/ctx-pipe-cat-wc-stddev.dat \
    $1/ctx-pipe-cat-sink.dat $1/ctx-pipe-cat-sink-stddev.dat

rscript_crop plots/diss-ctx-pipe/plot-1pe.R $1/eval-ctx-pipe-1pe.pdf --clip -4 \
    $1/ctx-pipe-rand-wc-1pe.dat $1/ctx-pipe-rand-wc-1pe-stddev.dat \
    $1/ctx-pipe-rand-sink-1pe.dat $1/ctx-pipe-rand-sink-1pe-stddev.dat \
    $1/ctx-pipe-cat-wc-1pe.dat $1/ctx-pipe-cat-wc-1pe-stddev.dat \
    $1/ctx-pipe-cat-sink-1pe.dat $1/ctx-pipe-cat-sink-1pe-stddev.dat

rscript_crop plots/diss-ctx-pipe/plot-idle.R $1/eval-ctx-pipe-idle.pdf --clip -4 \
    $1/ctx-pipe-rand-wc-idle.dat \
    $1/ctx-pipe-rand-sink-idle.dat \
    $1/ctx-pipe-cat-wc-idle.dat \
    $1/ctx-pipe-cat-sink-idle.dat
