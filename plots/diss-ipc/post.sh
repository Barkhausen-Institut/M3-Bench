#!/bin/sh

. tools/helper.sh

mhz=`get_mhz $1/m3-syscall-2-0/output.txt`

nova_total() {
    grep -P '! PingpongXPd\.cc.* \d+ cycles' $1/nre/gem5.log | \
        sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/'
}
nova_stddev() {
    grep -P '! PingpongXPd\.cc.* var: \d+' $1/nre/gem5.log | \
        sed -Ee 's/.* ([[:digit:]]+).*/\1/'
}

novaloc=`nova_total $1 | tail -n 1`
novarem=`nova_total $1 | head -n 1`
m3rem=`./tools/m3-bench.sh time 0000 $mhz 2 < $1/m3-syscall-2-0/gem5.log`
echo "$novaloc $novarem $m3rem" > $1/ipc-times.dat

novaloc=$(echo "scale=2;sqrt($(nova_stddev $1 | tail -n 1))" | bc)
novarem=$(echo "scale=2;sqrt($(nova_stddev $1 | head -n 1))" | bc)
m3rem=`./tools/m3-bench.sh stddev 0000 $mhz 2 < $1/m3-syscall-2-0/gem5.log`
echo "$novaloc $novarem $m3rem" > $1/ipc-stddev.dat
