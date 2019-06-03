#!/bin/zsh

mhz=3000

get_lx_total() {
    tail -n +2 $1/eval-app-$2-times.dat | awk '{ sum += $1 } END { print(sum) }'
}
get_m3_total() {
    ./m3/src/tools/bench.sh $1/m3-fstrace-ctx-$2-1-$3/gem5.log $mhz \
        | grep "TIME: 0000" | tail -n 3 | ./tools/m3-avg.awk
}
get_m3_stddev() {
    ./m3/src/tools/bench.sh $1/m3-fstrace-ctx-$2-1-$3/gem5.log $mhz \
        | grep "TIME: 0000" | tail -n 3 | ./tools/m3-stddev.awk
}

echo "m3-3" "m3-2" "m3-1" "lx" > $1/eval-app-ctx.dat
echo "m3-3" "m3-2" "m3-1" > $1/eval-app-ctx-stddev.dat
for tr in tar untar sha256sum sort find sqlite leveldb; do
    echo "Calculating time for $tr..."
    m33=`get_m3_total $1 $tr 0`
    m32=`get_m3_total $1 $tr 1`
    m31=`get_m3_total $1 $tr 2`
    lx=`get_lx_total $1 $tr`
    echo 1 $(((1. * $m31) / $m33)) $(((1. * $m32) / $m33)) $(((1. * $lx) / $m33)) >> $1/eval-app-ctx.dat

    m33s=`get_m3_stddev $1 $tr 0`
    m32s=`get_m3_stddev $1 $tr 1`
    m31s=`get_m3_stddev $1 $tr 2`
    echo $(((1. * $m33s) / $m33)) $(((1. * $m32s) / $m32)) $(((1. * $m31s) / $m31)) >> $1/eval-app-ctx-stddev.dat
done
