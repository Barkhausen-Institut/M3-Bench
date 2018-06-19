#!/bin/bash

Rscript plots/diss-vm-pf/plot.R $1/eval-pagefaults.pdf \
    $1/anon-1-times.dat \
    $1/anon-1-stddev.dat \
    $1/file-1-times.dat \
    $1/file-1-stddev.dat \
    $1/anon-4-times.dat \
    $1/anon-4-stddev.dat \
    $1/file-4-times.dat \
    $1/file-4-stddev.dat
