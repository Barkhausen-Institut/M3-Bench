#!/bin/bash

get_values() {
    for i in 16 32 64 128 256 512 1024 2048; do
        val=`grep 0001 $1/m3-$2-$i.txt | ./tools/m3-avg.awk`
        echo -n $(($val / 1024)) " "
    done
}

read_avgs=$1/m3-frag-read.dat
write_avgs=$1/m3-frag-write.dat

get_values $1 fsread | xargs > $read_avgs
get_values $1 fswrite | xargs > $write_avgs

Rscript plots/extents/plot.R $1/extents.pdf $read_avgs $write_avgs
