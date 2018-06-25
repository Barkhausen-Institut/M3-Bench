#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-scale-ctx-tar-1-1/output.txt`

get_avg() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "TIME: 0000" | ./tools/m3-avg.awk
}

echo -n > $1/app-scale-ctx.dat
for tr in tar untar find sqlite leveldb sha256sum sort; do
    echo "Generating times for $tr..."

    base=`get_avg $1/m3-scale-$tr-1-1/gem5.log`
    for apps in 1 2 4 8 16 32; do
        notfound=true
        for srv in 1 2 4; do
            if [ -f $1/m3-scale-ctx-$tr-$apps-$srv/gem5.log ]; then
                time=`get_avg $1/m3-scale-ctx-$tr-$apps-$srv/gem5.log`
                if [ "$time" = "" ]; then time=1; fi
                echo -n $((100 * (($base * 1.) / ($time * 1.)))) >> $1/app-scale-ctx.dat
                notfound=false
                break
            fi
        done
        if $notfound; then
            echo -n "NA" >> $1/app-scale-ctx.dat
        fi
        if [ $apps -ne 32 ]; then
            echo -n " " >> $1/app-scale-ctx.dat
        fi
    done
    echo >> $1/app-scale-ctx.dat
done
