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

get_name() {
    echo $1 | sed -e 's/m3fs-\(.*\)/\1-m3fs/'
}

get_ratio() {
    if [ "$2" = "" ]; then
        echo 0
    else
        echo "scale=8; ($1 * 1.0) / $2" | bc
    fi
}

gen_data() {
    echo "ratio stddev"
    echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$(get_name $2-64k)-alone.txt) $(get_m3_appavg $1/m3-rctmux-$(get_name $2-64k)-shared.txt)) 0
    echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$(get_name $2-128k)-alone.txt) $(get_m3_appavg $1/m3-rctmux-$(get_name $2-128k)-shared.txt)) 0
    echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$(get_name $2-256k)-alone.txt) $(get_m3_appavg $1/m3-rctmux-$(get_name $2-256k)-shared.txt)) 0
    echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$(get_name $2-512k)-alone.txt) $(get_m3_appavg $1/m3-rctmux-$(get_name $2-512k)-shared.txt)) 0
    echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$(get_name $2-1024k)-alone.txt) $(get_m3_appavg $1/m3-rctmux-$(get_name $2-1024k)-shared.txt)) 0
}

gen_data $1 "rand-wc"       > $1/m3-rctmux-rand-wc-times.dat
gen_data $1 "rand-sink"     > $1/m3-rctmux-rand-sink-times.dat
gen_data $1 "cat-wc"        > $1/m3-rctmux-cat-wc-times.dat
gen_data $1 "cat-sink"      > $1/m3-rctmux-cat-sink-times.dat
gen_data $1 "cat-wc-m3fs"   > $1/m3-rctmux-cat-wc-m3fs-times.dat

Rscript plots/rctmux-pipe/plot.R $1/m3-rctmux-pipe.pdf \
    $1/m3-rctmux-rand-wc-times.dat \
    $1/m3-rctmux-rand-sink-times.dat \
    $1/m3-rctmux-cat-wc-times.dat \
    $1/m3-rctmux-cat-sink-times.dat \
    $1/m3-rctmux-cat-wc-m3fs-times.dat
