#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/rctmux-pipe.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_LOG=Dtu,DtuRegWrite,DtuSysCalls,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    /bin/echo -e "\e[1mStarting $2-$3\e[0m"

    ./b run $cfg -n 1>$M3_GEM5_OUT/output.txt 2>&1

    if [ "`grep "Time: " $M3_GEM5_OUT/output.txt | wc -l`" = "2" ]; then
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

run_pipe() {
    jobs_started

    out=$1/m3-rctmux-$2-$4
    mkdir -p $out

    if [ "$4" = "alone" ]; then
        M3_GEM5_OUT=$out M3_CORES=7 M3_RCTMUX_ARGS="0 0 4 $3" run $1 $2 alone
    else
        M3_GEM5_OUT=$out M3_CORES=6 M3_RCTMUX_ARGS="1 0 4 $3" run $1 $2 shared
    fi
}

./b || exit 1

jobs_init $2

ds=$((2048 * 1024))
wr=/bin/rctmux-util-pipewr
rd=/bin/rctmux-util-piperd

for type in shared alone; do
    for comp in 32 64 128 256 512; do
        for per in 100 500 750 1000; do
            jobs_submit run_pipe $1 write-$per-$comp "3 2 $wr $ds $(($comp * $per)) $rd $(($comp * 1000))" $type
            jobs_submit run_pipe $1 read-$per-$comp  "3 2 $wr $ds $(($comp * 1000)) $rd $(($comp * $per))" $type
        done
    done

    jobs_submit run_pipe $1 rand-wc "2 1 /bin/rand $ds /bin/wc" $type
    jobs_submit run_pipe $1 cat-wc  "2 1 /bin/cat /data/512k.txt /bin/wc" $type
done

jobs_wait
