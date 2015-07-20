#!/bin/bash

if [ "$BLIND" != "" ]; then
    osname="XY"
    suffix="-blind"
else
    osname="M3"
fi

get_m3_ffttime() {
    grep -v 'TIME: 0000' $1 | awk '{ sum += $4 } END { print sum }'
}

avgs=$1/fft-times.dat

source tools/linux.sh

echo "Lx M3 M3-fft" > $avgs

# write into pipe, read from pipe and write into file
m3trans=$((32 * 1024 * 3 / 8))

m3total=`grep 0000 $1/m3-fft.txt | ./tools/m3-avg.awk`
m3tietotal=`grep 0000 $1/m3-ffttie.txt | ./tools/m3-avg.awk`
m3fft=`get_m3_ffttime $1/m3-fft.txt`
m3tiefft=`get_m3_ffttime $1/m3-ffttie.txt`
lxcp=`lx_avg $1/lx-30cycles.txt IDX_FFT_MEMCPY`

# we assume here that the FFT takes the same time on Linux as on M3, which is rougly true.
# it is slightly slower because of cache misses, but that is not important here.
echo $((`lx_avg $1/lx-30cycles.txt IDX_FFT` - $lxcp - $m3fft)) \
    $(($m3total - $m3trans - $m3fft)) \
    $(($m3tietotal - $m3trans - $m3tiefft)) >> $avgs
echo $lxcp $m3trans $m3trans  >> $avgs
echo $m3fft $m3fft $m3tiefft >> $avgs

Rscript plots/fft/plot.R $1/fft$suffix.pdf $osname $avgs
