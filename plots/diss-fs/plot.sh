#!/bin/bash

for pe in a b c; do
    Rscript plots/diss-fs/plot.R $1/eval-fs-$pe.pdf \
        $1/fs-$pe-read.dat $1/fs-$pe-read-stddev.dat \
        $1/fs-$pe-write.dat $1/fs-$pe-write-stddev.dat \
        $1/fs-$pe-copy.dat $1/fs-$pe-copy-stddev.dat
done
