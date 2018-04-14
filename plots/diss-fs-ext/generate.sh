#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-fs-read-a-8/output.txt`

m3_total() {
    ./tools/m3-bench.sh time 0001 $mhz 0 < $1/m3-fs-$2-$3-$4/gem5.log
}

echo "Read Write Copy" > $1/fs-a-ext.dat
for bpe in 2 4 8 16 32 64 128 256; do
    rd=`m3_total $1 read a $bpe`
    wr=`m3_total $1 write a $bpe`
    cp=`m3_total $1 copy a $bpe`
    echo "$rd $wr $cp" >> $1/fs-a-ext.dat
done

Rscript plots/diss-fs-ext/plot.R $1/eval-fs-ext.pdf $1/fs-a-ext.dat
