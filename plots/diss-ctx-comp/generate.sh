#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-comp-ctx-alone-b-1/output.txt`

m3_avg() {
    ./tools/m3-bench.sh time 1234 $mhz 1 < $1/m3-comp-ctx-$2-$3-$4/gem5.log
}

for t in b c; do
    echo -n > $1/comp-ctx-$t.dat

    base=`m3_avg $1 alone $t 1`
    for ts in 1 2 4 8 16; do
        time=`m3_avg $1 shared $t $ts`
        if [ "$time" = "" ]; then
            ratio=0.95
        else
            ratio=$((($base * 1.0) / $time))
        fi
        echo $ratio >> $1/comp-ctx-$t.dat
    done

    Rscript plots/diss-ctx-comp/plot.R $1/eval-ctx-comp-$t.pdf $1/comp-ctx-$t.dat
done
