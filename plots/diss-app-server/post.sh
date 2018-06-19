#!/bin/zsh

. tools/helper.sh

set -x

mhz=`get_mhz $1/m3-server-nginx-1-1/output.txt`

get_max() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "TIME: 0000" | awk '{ if($4 > max) max = $4 } END { print(max) }'
}

for tr in nginx; do
    echo "Generating app-server-$tr.dat..."
    echo "s1 s2 s4 s8" > $1/app-server-$tr.dat

    for apps in 1 2 4 8 16 32; do
        for srv in 1 2 4 8; do
            if [ -f $1/m3-server-$tr-$apps-$srv/gem5.log ]; then
                time=`get_max $1/m3-server-$tr-$apps-$srv/gem5.log`
                echo -n $(($apps * 33 * (1000000000 / ($time / 3)))) >> $1/app-server-$tr.dat
            else
                echo -n "NA" >> $1/app-server-$tr.dat
            fi
            if [ $srv -ne 8 ]; then
                echo -n " " >> $1/app-server-$tr.dat
            fi
        done
        echo >> $1/app-server-$tr.dat
    done
done
