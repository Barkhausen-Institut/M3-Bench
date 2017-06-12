#!/bin/sh

. tools/helper.sh

mhz=`get_mhz $1/m3-syscall-0-0/output.txt`

lx=`cut -d ' ' -f 1 $1/lx-syscall/res.txt`
m300=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-0-0/gem5.log`
m310=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-1-0/gem5.log`
m311=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-1-1/gem5.log`
m312=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-1-2/gem5.log`
echo "$lx $m300 $m310 $m311 $m312" > $1/syscall_asplos18-times.dat

lx=`cut -d ' ' -f 2 $1/lx-syscall/res.txt`
m300=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-0-0/gem5.log`
m310=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-1-0/gem5.log`
m311=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-1-1/gem5.log`
m312=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-1-2/gem5.log`
echo "$lx $m300 $m310 $m311 $m312" > $1/syscall_asplos18-stddev.dat

Rscript plots/syscall_asplos18/plot.R $1/syscall_asplos18.pdf \
    $1/syscall_asplos18-times.dat \
    $1/syscall_asplos18-stddev.dat
