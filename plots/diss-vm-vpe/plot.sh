#!/bin/bash

. tools/helper.sh

rscript_crop plots/diss-vm-vpe/plot.R $1/eval-vm-vpe-clone.pdf \
    $1/clone-times.dat \
    $1/clone-stddev.dat
rscript_crop plots/diss-vm-vpe/plot.R $1/eval-vm-vpe-exec.pdf \
    $1/exec-times.dat \
    $1/exec-stddev.dat
