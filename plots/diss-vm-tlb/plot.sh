#!/bin/bash

Rscript plots/diss-vm-tlb/plot.R $1/eval-vm-tlb.pdf \
    $1/tlbmiss.dat \
    $1/tlbmiss-stddev.dat
