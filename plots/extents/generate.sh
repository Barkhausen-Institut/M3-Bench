#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-extents-rd-16/output.txt`

read_avgs=$1/m3-frag-read.dat
write_avgs=$1/m3-frag-write.dat

echo -n > $read_avgs
echo -n > $write_avgs

bpe="16 32 64 128 256 512"
for b in $bpe; do
    ./m3/src/tools/bench.sh $1/m3-extents-rd-$b/gem5.log $mhz 0 | grep "TIME: 0001" | awk '{ print $4 }' >> $read_avgs
    ./m3/src/tools/bench.sh $1/m3-extents-wr-$b/gem5.log $mhz 0 | grep "TIME: 0001" | awk '{ print $4 }' >> $write_avgs
done

Rscript plots/extents/plot.R $1/extents.pdf $read_avgs $write_avgs
