#!/bin/bash

. tools/helper.sh

for pe in a b c; do
    rscript_crop plots/diss-fs/plot.R $1/eval-fs-$pe.pdf --clip -12 \
        $1/fs-$pe-read.dat $1/fs-$pe-read-stddev.dat \
        $1/fs-$pe-write.dat $1/fs-$pe-write-stddev.dat \
        $1/fs-$pe-copy.dat $1/fs-$pe-copy-stddev.dat
done
