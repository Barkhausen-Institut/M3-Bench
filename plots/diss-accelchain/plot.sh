#!/bin/zsh

Rscript plots/diss-accelchain/plot-time.R $1/eval-accelchain-times.pdf \
    $1/accelchain-1-times.dat \
    $1/accelchain-2-times.dat \
    $1/accelchain-4-times.dat \
    $1/accelchain-8-times.dat

Rscript plots/diss-accelchain/plot-util.R $1/eval-accelchain-util.pdf \
    $1/accelchain-1-util.dat $1/accelchain-1-sleep.dat \
    $1/accelchain-2-util.dat $1/accelchain-2-sleep.dat \
    $1/accelchain-4-util.dat $1/accelchain-4-sleep.dat \
    $1/accelchain-8-util.dat $1/accelchain-8-sleep.dat
