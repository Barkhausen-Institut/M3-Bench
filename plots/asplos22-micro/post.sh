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

m3sh=$(extract_m3_time $1/m3-ipc/output.txt local)
m3ex=$(extract_m3_time $1/m3-ipc/output.txt remote)
lxsys=$(cut -d ' ' -f 1 $1/lx-syscall/res.txt)
lxyield=$(cut -d ' ' -f 1 $1/lx-yield/res.txt)
echo $m3ex $m3sh $lxsys $lxyield > $1/micro-times.dat

m3sh=$(extract_m3_stddev $1/m3-ipc/output.txt local)
m3ex=$(extract_m3_stddev $1/m3-ipc/output.txt remote)
lxsys=$(cut -d ' ' -f 2 $1/lx-syscall/res.txt)
lxyield=$(cut -d ' ' -f 2 $1/lx-yield/res.txt)
echo $m3ex $m3sh $lxsys $lxyield > $1/micro-stddev.dat
