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

m3rdex=$(extract_m3_time $1/m3-fs/output.txt read)
m3wrex=$(extract_m3_time $1/m3-fs/output.txt write)
m3rdsh=$(extract_m3_time $1/m3-fs-shared/output.txt read)
m3wrsh=$(extract_m3_time $1/m3-fs-shared/output.txt write)
lxrd=$(cut -d ' ' -f 1 $1/lx-read/res.txt)
lxwr=$(cut -d ' ' -f 1 $1/lx-write/res.txt)
echo $m3rdex $m3rdsh $m3wrex $m3wrsh $lxrd $lxwr > $1/fs-times.dat

m3rdex=$(extract_m3_stddev $1/m3-fs/output.txt read)
m3wrex=$(extract_m3_stddev $1/m3-fs/output.txt write)
m3rdsh=$(extract_m3_stddev $1/m3-fs-shared/output.txt read)
m3wrsh=$(extract_m3_stddev $1/m3-fs-shared/output.txt write)
lxrd=$(cut -d ' ' -f 2 $1/lx-read/res.txt)
lxwr=$(cut -d ' ' -f 2 $1/lx-write/res.txt)
echo $m3rdex $m3rdsh $m3wrex $m3wrsh $lxrd $lxwr > $1/fs-stddev.dat
