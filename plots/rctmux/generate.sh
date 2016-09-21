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
    # echo `get_m3_xfertime $alone` `get_m3_xfertime $shared`
    echo `get_m3_appavg $alone` `get_m3_appavg $shared` `get_m3_appsd $alone` `get_m3_appsd $shared`
}

gen_data $1 "tar"    > $1/m3-rctmux-tar-times.dat
gen_data $1 "untar"  > $1/m3-rctmux-untar-times.dat
gen_data $1 "find"   > $1/m3-rctmux-find-times.dat
gen_data $1 "sqlite" > $1/m3-rctmux-sqlite-times.dat

Rscript plots/rctmux/plot.R $1/m3-rctmux.pdf \
    $1/m3-rctmux-tar-times.dat \
    $1/m3-rctmux-untar-times.dat \
    $1/m3-rctmux-find-times.dat \
    $1/m3-rctmux-sqlite-times.dat
