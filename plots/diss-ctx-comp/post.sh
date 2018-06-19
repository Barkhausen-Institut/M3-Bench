#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-comp-ctx-alone-b-1/output.txt`

m3_avg() {
    ./tools/m3-bench.sh time 1234 $mhz 1 < $1/m3-comp-ctx-$2-$3-$4/gem5.log
}
m3_stddev() {
    ./tools/m3-bench.sh stddev 1234 $mhz 1 < $1/m3-comp-ctx-$2-$3-$4/gem5.log
}

for t in c; do
    echo -n > $1/comp-ctx-$t.dat
    echo -n > $1/comp-ctx-$t-stddev.dat

    base=`m3_avg $1 alone $t 1`
    basestddev=`m3_stddev $1 alone $t 1`
    echo $((100.0 * ($basestddev * 1. / $base))) >> $1/comp-ctx-$t-stddev.dat
    for ts in 1 2 4 8; do
        time=`m3_avg $1 shared $t $ts`
        if [ "$time" = "" ]; then
            ratio=0.95
        else
            ratio=$((($base * 1.0) / $time))
        fi
        echo $ratio >> $1/comp-ctx-$t.dat

        stddev=`m3_stddev $1 shared $t $ts`
        echo $((100.0 * ($stddev * 1. / $time))) >> $1/comp-ctx-$t-stddev.dat
    done
done
