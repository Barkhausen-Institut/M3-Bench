#!/bin/sh

grep -P '! PingpongXPd\.cc.* \d+ cycles' $1/nre/gem5.log | \
    sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/' > $1/nre-ipc.txt
grep -P '! PingpongXPd\.cc.* var: \d+' $1/nre/gem5.log | \
    sed -Ee 's/.* ([[:digit:]]+).*/\1/' > $1/nre-ipc-var.txt

novaloc=`tail -n 1 $1/nre-ipc.txt`
novarem=`head -n 1 $1/nre-ipc.txt`
m3rem=`./tools/m3-bench.sh time 0000 2 < $1/m3-syscall/gem5.log`
echo "$novaloc $novarem $m3rem" > $1/ipc-times.dat

novaloc=$(echo "scale=2;sqrt($(tail -n 1 $1/nre-ipc-var.txt))" | bc)
novarem=$(echo "scale=2;sqrt($(head -n 1 $1/nre-ipc-var.txt))" | bc)
m3rem=`./tools/m3-bench.sh stddev 0000 2 < $1/m3-syscall/gem5.log`
echo "$novaloc $novarem $m3rem" > $1/ipc-stddev.dat

Rscript plots/ipc/plot.R $1/eval-ipc.pdf $1/ipc-times.dat $1/ipc-stddev.dat
