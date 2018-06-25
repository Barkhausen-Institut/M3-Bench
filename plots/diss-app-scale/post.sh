#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-scale-tar-1-1/output.txt`

get_avg() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "TIME: 0000" | ./tools/m3-avg.awk
}

for tr in tar untar find sqlite leveldb sha256sum sort; do
    echo "Generating app-scale-$tr.dat..."
    echo "s1 s2 s4 s8" > $1/app-scale-$tr.dat

    base=`get_avg $1/m3-scale-$tr-1-1/gem5.log`
    for apps in 1 2 4 8 16 32; do
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
done
