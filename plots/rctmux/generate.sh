#!/bin/bash

get_m3_appavg() {
    ./tools/m3-bench.sh time 1234 1000 2 < $1
}
get_m3_appsd() {
    ./tools/m3-bench.sh stddev 1234 1000 2 < $1
}
get_ratio() {
    echo "scale=8; ($1 * 1.0) / $2" | bc
}
gen_data() {
    echo "ratio stddev"
    echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$2-alone/gem5.log) $(get_m3_appavg $1/m3-rctmux-$2-shared/gem5.log)) 0
}
gen_sd() {
    ti=$(get_m3_appavg $1/m3-rctmux-$3-$2/gem5.log)
    sd=$(get_m3_appsd $1/m3-rctmux-$3-$2/gem5.log)
    echo $sd $ti $(get_ratio $sd $ti)
}

gen_data $1 "tar"    > $1/m3-rctmux-tar-times.dat
gen_data $1 "untar"  > $1/m3-rctmux-untar-times.dat
gen_data $1 "find"   > $1/m3-rctmux-find-times.dat
gen_data $1 "sqlite" > $1/m3-rctmux-sqlite-times.dat

echo "stddev runtime percent" > $1/m3-rctmux-alone-sd.dat
echo "stddev runtime percent" > $1/m3-rctmux-shared-sd.dat
for a in tar untar find sqlite; do
    echo "Generating times for $a-alone..."
    gen_sd $1 alone $a >> $1/m3-rctmux-alone-sd.dat
    echo "Generating times for $a-shared..."
    gen_sd $1 shared $a >> $1/m3-rctmux-shared-sd.dat
done

Rscript plots/rctmux/plot.R $1/m3-rctmux.pdf \
    $1/m3-rctmux-tar-times.dat \
    $1/m3-rctmux-untar-times.dat \
    $1/m3-rctmux-find-times.dat \
    $1/m3-rctmux-sqlite-times.dat
