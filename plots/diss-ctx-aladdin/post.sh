#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-aladdin-fft-0-1-file-1/output.txt`

for b in stencil md fft spmv; do
    echo -n > $1/$b-file-times.dat
    echo -n > $1/$b-file-stddev.dat
    for ts in 1 2 4; do
        echo "Generating times for $b-$ts-file..."
        base=`./tools/m3-bench.sh time 1234 $mhz 1 < $1/m3-aladdin-$b-0-1-file-$ts/gem5.log`
        time=`./tools/m3-bench.sh time 1234 $mhz 1 < $1/m3-aladdin-$b-0-2-file-$ts/gem5.log`
        echo $((($time * 1.0) / $base)) >> $1/$b-file-times.dat

        stddev=`./tools/m3-bench.sh stddev 1234 $mhz 1 < $1/m3-aladdin-$b-0-2-file-$ts/gem5.log`
        echo $((($stddev * 1.0) / $time)) >> $1/$b-file-stddev.dat
    done
done
