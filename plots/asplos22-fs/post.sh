#!/bin/sh

. tools/helper.sh

extract_m3_time() {
    grep "PERF" $1 | \
        grep $2 | \
        sed -e 's/\x1b\[0m//g' | \
        sed -re 's/.*PERF "\S+.*": ([0-9]*).*/\1/'
}

extract_m3_stddev() {
    grep "PERF" $1 | \
        grep $2 | \
        sed -e 's/\x1b\[0m//g' | \
        sed -re 's/.*PERF "\S+.*": [0-9]*.*- ([0-9.]*).*/\1/'
}

cycles_to_tput() {
    # 2 MiB file, BOOM runs at 80 MHz
    echo "2 * 1024 * 1024 * (80000000 / $1)" | bc
}

stddev_to_tput() {
    echo "$3 / ($2 / $1)" | bc
}

m3rdextime=$(extract_m3_time $1/m3-fs/output.txt read)
m3wrextime=$(extract_m3_time $1/m3-fs/output.txt write)
m3rdshtime=$(extract_m3_time $1/m3-fs-shared/output.txt read)
m3wrshtime=$(extract_m3_time $1/m3-fs-shared/output.txt write)
lxrdtime=$(cut -d ' ' -f 1 $1/lx-read/res.txt)
lxwrtime=$(cut -d ' ' -f 1 $1/lx-write/res.txt)
echo $m3rdextime $m3rdshtime $m3wrextime $m3wrshtime $lxrdtime $lxwrtime > $1/fs-times.dat

m3rdex=$(cycles_to_tput $m3rdextime)
m3wrex=$(cycles_to_tput $m3wrextime)
m3rdsh=$(cycles_to_tput $m3rdshtime)
m3wrsh=$(cycles_to_tput $m3wrshtime)
lxrd=$(cycles_to_tput $lxrdtime)
lxwr=$(cycles_to_tput $lxwrtime)
echo $m3rdex $m3rdsh $m3wrex $m3wrsh $lxrd $lxwr > $1/fs-tputs.dat

m3rdexdev=$(extract_m3_stddev $1/m3-fs/output.txt read)
m3wrexdev=$(extract_m3_stddev $1/m3-fs/output.txt write)
m3rdshdev=$(extract_m3_stddev $1/m3-fs-shared/output.txt read)
m3wrshdev=$(extract_m3_stddev $1/m3-fs-shared/output.txt write)
lxrddev=$(cut -d ' ' -f 2 $1/lx-read/res.txt)
lxwrdev=$(cut -d ' ' -f 2 $1/lx-write/res.txt)

m3rdex=$(stddev_to_tput $m3rdexdev $m3rdextime $m3rdex)
m3wrex=$(stddev_to_tput $m3wrexdev $m3wrextime $m3wrex)
m3rdsh=$(stddev_to_tput $m3rdshdev $m3rdshtime $m3rdsh)
m3wrsh=$(stddev_to_tput $m3wrshdev $m3wrshtime $m3wrsh)
lxrd=$(stddev_to_tput $lxrddev $lxrdtime $lxrd)
lxwr=$(stddev_to_tput $lxwrdev $lxwrtime $lxwr)
echo $m3rdex $m3rdsh $m3wrex $m3wrsh $lxrd $lxwr > $1/fs-stddev.dat
