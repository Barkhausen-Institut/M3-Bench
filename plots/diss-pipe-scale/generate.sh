#!/bin/zsh

. tools/helper.sh

set -x

mhz=`get_mhz $1/m3-scale-pipe-cat-wc-1-0/output.txt`

get_avg() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "TIME: 1234" | ./tools/m3-avg.awk
}

echo "s1 s2 s4 s8 s16" > $1/pipe-scale.dat
for tr in cat-wc cat-awk grep-wc grep-awk; do
    echo "Adding $tr..."

    base=`get_avg $1/m3-scale-pipe-$tr-1-0/gem5.log`
    for apps in 1 2 4 8 16; do
        time=`get_avg $1/m3-scale-pipe-$tr-$apps-0/gem5.log`
        echo -n $((100 * (($base * 1.) / ($time * 1.)))) >> $1/pipe-scale.dat
        if [ $apps -ne 16 ]; then
            echo -n " " >> $1/pipe-scale.dat
        fi
    done

    echo >> $1/pipe-scale.dat
done

rscript_crop plots/diss-pipe-scale/plot.R $1/eval-pipe-scale.pdf $1/pipe-scale.dat
