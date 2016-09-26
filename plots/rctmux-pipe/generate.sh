#!/bin/bash

get_m3_ctxtime() {
    grep 'TIME: cccc' $1 | awk '{ sum += $4 } END { print sum }'
}
get_m3_xfertime() {
    grep 'TIME: aaaa' $1 | awk '{ sum += $4 } END { print sum }'
}
get_m3_appavg() {
    grep 'TIME: 1234' $1 | ./tools/m3-avg.awk
}
get_m3_appsd() {
    grep 'TIME: 1234' $1 | ./tools/m3-stddev.awk
}

gen_data() {
    alone=$1/m3-rctmux-$2-alone.txt
    shared=$1/m3-rctmux-$2-shared.txt
    echo "Alone Shared AloneSD SharedSD"
    # echo `get_m3_ctxtime $alone` `get_m3_ctxtime $shared`
    xferalone=`get_m3_xfertime $alone`
    xfershared=`get_m3_xfertime $shared`
    echo $xferalone $xfershared 0 0
    echo $((`get_m3_appavg $alone` - $xferalone)) $((`get_m3_appavg $shared` - $xfershared)) `get_m3_appsd $alone` `get_m3_appsd $shared`
}

gen_data $1 "rand-wc"   > $1/m3-rctmux-rand-wc-times.dat
gen_data $1 "rand-sink" > $1/m3-rctmux-rand-sink-times.dat
gen_data $1 "cat-wc"    > $1/m3-rctmux-cat-wc-times.dat
gen_data $1 "cat-sink"  > $1/m3-rctmux-cat-sink-times.dat

Rscript plots/rctmux-pipe/plot.R $1/m3-rctmux-pipe.pdf \
    $1/m3-rctmux-rand-wc-times.dat \
    $1/m3-rctmux-rand-sink-times.dat \
    $1/m3-rctmux-cat-wc-times.dat \
    $1/m3-rctmux-cat-sink-times.dat
