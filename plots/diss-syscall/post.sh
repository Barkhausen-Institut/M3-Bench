#!/bin/sh

. tools/helper.sh

mhz=`get_mhz $1/m3-syscall-2-0/output.txt`

awk -v mhz=$mhz '
BEGIN {
    times[0] = 0
    times[1] = 0
    times[2] = 0
    count = 0
}

/DEBUG.*1ff10000/ {
    p = 1
    match($0, /^([[:digit:]]*):/, res)
    start = res[1]
}

/Starting command SEND/ {
    if (p) {
        match($0, /^([[:digit:]]+):/, res)
        if (count >= 2)
            times[0] += res[1] - start
        start = res[1]
    }
}

/Finished command SEND/ {
    if (p) {
        match($0, /^([[:digit:]]+):/, res)
        if (count >= 2)
            times[1] += res[1] - start
        start = res[1]
    }
}

/Starting command REPLY/ {
    if (p) {
        match($0, /^([[:digit:]]+):/, res)
        if (count >= 2)
            times[2] += res[1] - start
        start = res[1]
    }
}

/Finished command REPLY/ {
    if (p) {
        match($0, /^([[:digit:]]+):/, res)
        if (count >= 2)
            times[1] += res[1] - start
        start = res[1]
    }
}

/DEBUG.*1ff20000/ {
    match($0, /^([[:digit:]]+):/, res)
    if (count >= 2)
        times[0] += res[1] - start
    count += 1
    p = 0
}

function ticksToCycles(ticks) {
    return ticks * (mhz / 1000000)
}

END {
    count -= 2
    printf "pre-post : %d\n", ticksToCycles(times[0] / count)
    printf "messaging: %d\n", ticksToCycles(times[1] / count)
    printf "kernel   : %d\n", ticksToCycles(times[2] / count)
}' $1/m3-syscall-2-0/gem5.log > $1/m3-syscall-detail.txt

lx=`cut -d ' ' -f 1 $1/lx-syscall/res.txt`
nova=`grep -P '! Syscall\.cc.* PERF:.*\d+ cycles' $1/nre/gem5.log | sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/'`
m3=`./tools/m3-bench.sh time 0000 $mhz 5 < $1/m3-syscall-2-0/gem5.log`
echo "$lx $nova $m3" > $1/syscall-times.dat

lx=`cut -d ' ' -f 2 $1/lx-syscall/res.txt`
nova=`grep -P '! Syscall\.cc.* var: \d+' $1/nre/gem5.log | sed -Ee 's/.* ([[:digit:]]+).*/\1/'`
nova=$(echo "scale=2;sqrt($nova)" | bc)
m3=`./tools/m3-bench.sh stddev 0000 $mhz 5 < $1/m3-syscall-2-0/gem5.log`
echo "$lx $nova $m3" > $1/syscall-stddev.dat
