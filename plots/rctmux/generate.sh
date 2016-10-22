#!/bin/bash

get_m3_appavg() {
    grep 'TIME: 1234' $1 | tail -n 7 | ./tools/m3-avg.awk
}
get_m3_appsd() {
    grep 'TIME: 1234' $1 | tail -n 7 | ./tools/m3-stddev.awk
}
get_ratio() {
    echo "scale=8; ($1 * 1.0) / $2" | bc
}
gen_data() {
    echo "ratio stddev"
    echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$2-alone.txt) $(get_m3_appavg $1/m3-rctmux-$2-shared.txt)) 0
}
gen_sd() {
    ti=$(get_m3_appavg $1/m3-rctmux-$3-$2.txt)
    sd=$(get_m3_appsd $1/m3-rctmux-$3-$2.txt)
    echo $sd $ti $(get_ratio $sd $ti)
}

gen_data $1 "tar"    > $1/m3-rctmux-tar-times.dat
gen_data $1 "untar"  > $1/m3-rctmux-untar-times.dat
gen_data $1 "find"   > $1/m3-rctmux-find-times.dat
gen_data $1 "sqlite" > $1/m3-rctmux-sqlite-times.dat

echo "stddev runtime percent" > $1/m3-rctmux-alone-sd.dat
echo "stddev runtime percent" > $1/m3-rctmux-shared-sd.dat
for a in tar untar find sqlite; do
    gen_sd $1 alone $a >> $1/m3-rctmux-alone-sd.dat
    gen_sd $1 shared $a >> $1/m3-rctmux-shared-sd.dat
done

Rscript plots/rctmux/plot.R $1/m3-rctmux.pdf \
    $1/m3-rctmux-tar-times.dat \
    $1/m3-rctmux-untar-times.dat \
    $1/m3-rctmux-find-times.dat \
    $1/m3-rctmux-sqlite-times.dat
