#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-syscall-0-0/output.txt`

m300=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-0-0/gem5.log`
m310=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-1-0/gem5.log`
m312=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-1-2/gem5.log`
m320=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-2-0/gem5.log`
echo "$m320 $m300 $m312 $m310" > $1/vm-sysc-times.dat

m300=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-0-0/gem5.log`
m310=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-1-0/gem5.log`
m312=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-1-2/gem5.log`
m320=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-2-0/gem5.log`
echo "$m320 $m300 $m312 $m310" > $1/vm-sysc-stddev.dat
