#!/bin/bash

. tools/helper.sh

rscript_crop plots/diss-vm-pipe/plot.R $1/eval-pipe.pdf --clip -11 \
    $1/pipe-total.dat $1/pipe-total-stddev.dat \
    $1/pipe-read.dat $1/pipe-read-stddev.dat \
    $1/pipe-write.dat $1/pipe-write-stddev.dat
