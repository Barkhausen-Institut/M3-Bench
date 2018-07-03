#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-accelchain-ctx-1-1-1/output.txt`

for num in 1 2 4 8; do
    echo -n > $1/accelchain-ctx-$num-times.dat

    for ts in 1 2 4; do
        echo "Generating times for ts=$ts num=$num..."

        base=`./m3/src/tools/bench.sh $1/m3-accelchain-ctx-1-$num-$ts/gem5.log $mhz 1 | \
            grep "TIME: 0000" | ./tools/m3-avg.awk`
        time=`./m3/src/tools/bench.sh $1/m3-accelchain-ctx-3-$num-$ts/gem5.log $mhz 1 | \
            grep "TIME: 0000" | ./tools/m3-avg.awk`

        echo $(((1. * $time) / ($base * 2))) >> $1/accelchain-ctx-$num-times.dat
    done
done
