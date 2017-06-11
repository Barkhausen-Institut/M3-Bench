#!/bin/sh

./m3/src/tools/bench.sh $1/m3-syscall/gem5.log 2 > $1/m3-syscall.txt

awk '
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

END {
    count -= 2
    for(i in times) {
        printf "%d\n", times[i] / count
    }
}' $1/m3-syscall/gem5.log > $1/m3-syscall-detail.txt

lx=`cut -d ' ' -f 1 $1/lx-syscall.txt`
nova=`grep -P '! Syscall\.cc.* PERF:.*\d+ cycles' $1/nre/gem5.log | sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/'`
m3=`./tools/m3-bench.sh time 0000 5 < $1/m3-syscall/gem5.log`
echo "$lx $nova $m3" > $1/syscall-times.dat

lx=`cut -d ' ' -f 2 $1/lx-syscall.txt`
nova=`grep -P '! Syscall\.cc.* var: \d+' $1/nre/gem5.log | sed -Ee 's/.* ([[:digit:]]+).*/\1/'`
m3=`./tools/m3-bench.sh stddev 0000 5 < $1/m3-syscall/gem5.log`
echo "$lx $nova $m3" > $1/syscall-stddev.dat

Rscript plots/syscall/plot.R $1/eval-syscall.pdf $1/syscall-times.dat $1/syscall-stddev.dat
