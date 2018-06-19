#!/bin/bash

. tools/helper.sh

rscript_crop plots/diss-vm-sysc/plot.R $1/eval-vm-sysc.pdf \
    $1/vm-sysc-times.dat \
    $1/vm-sysc-stddev.dat
