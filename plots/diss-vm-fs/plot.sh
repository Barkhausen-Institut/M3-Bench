#!/bin/bash

Rscript plots/diss-vm-fs/plot.R $1/eval-fs.pdf \
    $1/fs-read.dat $1/fs-read-stddev.dat \
    $1/fs-write.dat $1/fs-write-stddev.dat \
    $1/fs-copy.dat $1/fs-copy-stddev.dat
