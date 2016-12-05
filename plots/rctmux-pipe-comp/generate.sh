#!/bin/bash

get_m3_appavg() {
    if [ "`grep 'TIME: 1234' $1 | tail -n +2`" != "" ]; then
        grep 'TIME: 1234' $1 | tail -n +2 | ./tools/m3-avg.awk
    else
        echo 1
    fi
}
get_lx_appavg() {
    if [ "`grep "Total time" $1`" != "" ]; then
        grep "Total time" $1 | awk '{ print $4 }'
    else
        echo 1
    fi
}
get_ratio() {
    if [ "$2" = "" ]; then
        echo 0
    else
        echo "scale=8; ($1 * 1.0) / $2" | bc
    fi
}

gen_data() {
    echo "ratio"
    for s in $sizes; do
        echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$2-$s-alone.txt) $(get_m3_appavg $1/m3-rctmux-$2-$s-shared.txt))
    done
}
gen_abs_data() {
    echo "time"
    for s in $sizes; do
        echo $(get_m3_appavg $1/m3-rctmux-$2-$s-alone.txt)
        echo $(get_m3_appavg $1/m3-rctmux-$2-$s-shared.txt)
        echo $(get_lx_appavg $1/lx-$2-$s-output.txt)
    done
}

sizes="32 64 128 256 512"

for a in read write; do
    for comp in 100 500 750 1000; do
        gen_data $1 $a-$comp > $1/m3-rctmux-$a-$comp-times.dat
        gen_abs_data $1 $a-$comp > $1/m3-rctmux-$a-$comp-abstimes.dat
    done
done

sizes="512k"

gen_data $1 rand-wc > $1/m3-rctmux-rand-wc-times.dat
gen_abs_data $1 rand-wc > $1/m3-rctmux-rand-wc-abstimes.dat

Rscript plots/rctmux-pipe-comp/plot-ratio.R $1/m3-rctmux-pipe-comp-ratio.pdf \
    $1/m3-rctmux-read-100-times.dat \
    $1/m3-rctmux-read-500-times.dat \
    $1/m3-rctmux-read-750-times.dat \
    $1/m3-rctmux-read-1000-times.dat \
    $1/m3-rctmux-write-100-times.dat \
    $1/m3-rctmux-write-500-times.dat \
    $1/m3-rctmux-write-750-times.dat

Rscript plots/rctmux-pipe-comp/plot-abs.R $1/m3-rctmux-pipe-comp-abs.pdf \
    $1/m3-rctmux-read-100-abstimes.dat \
    $1/m3-rctmux-read-500-abstimes.dat \
    $1/m3-rctmux-read-750-abstimes.dat \
    $1/m3-rctmux-read-1000-abstimes.dat \
    $1/m3-rctmux-write-100-abstimes.dat \
    $1/m3-rctmux-write-500-abstimes.dat \
    $1/m3-rctmux-write-750-abstimes.dat
