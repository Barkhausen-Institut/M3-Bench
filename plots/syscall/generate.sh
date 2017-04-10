#!/bin/sh

lx=`cut -d ' ' -f 1 $1/lx-syscall.txt`
nova=`grep -P '! Syscall\.cc.* PERF:.*\d+ cycles' $1/nre/gem5.log | sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/'`
m3=`./tools/m3-bench.sh time 0000 5 < $1/m3-syscall/gem5.log`
echo "$lx $nova $m3" > $1/syscall-times.dat

lx=`cut -d ' ' -f 2 $1/lx-syscall.txt`
nova=`grep -P '! Syscall\.cc.* var: \d+' $1/nre/gem5.log | sed -Ee 's/.* ([[:digit:]]+).*/\1/'`
m3=`./tools/m3-bench.sh stddev 0000 5 < $1/m3-syscall/gem5.log`
echo "$lx $nova $m3" > $1/syscall-stddev.dat

Rscript plots/syscall/plot.R $1/eval-syscall.pdf $1/syscall-times.dat $1/syscall-stddev.dat
