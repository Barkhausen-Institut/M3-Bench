#!/bin/zsh

. tools/helper.sh

set -x

mhz=`get_mhz $1/m3-scale-tar-1-1/output.txt`

get_avg() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "TIME: 0000" | ./tools/m3-avg.awk
}

for tr in sha256sum sort; do
    echo "Generating app-scale-$tr.dat..."
    echo "s1 s2 s4 s8" > $1/app-scale-$tr.dat

    base=`get_avg $1/m3-scale-$tr-1-1/gem5.log`
    for apps in 1 2 4 8 16 32; do
        if [ $apps -eq 32 ]; then
            last=`get_avg $1/m3-scale-$tr-$apps-2/gem5.log`
        else
            last=`get_avg $1/m3-scale-$tr-$apps-1/gem5.log`
        fi

        for srv in 1 2 4 8; do
            if [ -f $1/m3-scale-$tr-$apps-$srv/gem5.log ]; then
                time=`get_avg $1/m3-scale-$tr-$apps-$srv/gem5.log`
                if [ "$time" = "" ]; then time=1; fi
                echo -n $((100 * (($base * 1.) / ($time * 1.)))) >> $1/app-scale-$tr.dat
            else
                echo -n "NA" >> $1/app-scale-$tr.dat
            fi
            if [ $srv -ne 8 ]; then
                echo -n " " >> $1/app-scale-$tr.dat
            fi
        done
        echo >> $1/app-scale-$tr.dat
    done

    rscript_crop plots/diss-app-scale/plot.R $1/eval-app-scale-$tr.pdf $1/app-scale-$tr.dat
done
