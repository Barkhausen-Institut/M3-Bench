#!/bin/bash

cd m3
export M3_BUILD=bench

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

export M3_GEM5_OUT=$1/m3-syscall
mkdir -p $M3_GEM5_OUT

echo > $1/m3-syscall-output.txt

./b run boot/bench-syscall.cfg 1>$1/m3-syscall-output.txt 2>&1

if [ $? -eq 0 ]; then
    ./src/tools/bench.sh $M3_GEM5_OUT/gem5.log 2 > $1/m3-syscall.txt

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
fi
