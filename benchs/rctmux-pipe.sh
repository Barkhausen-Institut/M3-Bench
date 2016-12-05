#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/rctmux-pipe.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuSysCalls,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

run() {
    /bin/echo -e "\e[1mStarting $2-$3\e[0m"

    ./b run $cfg -n 1>$1/m3-rctmux-$2-$3-output.txt 2>&1

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
        ./src/tools/bench.sh $M3_GEM5_OUT/gem5.log > $1/m3-rctmux-$2-$3.txt
    else
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

run_pipe() {
    jobs_started

    out=$1/m3-rctmux-$2-$4
    mkdir -p $out

    if [ "$4" = "alone" ]; then
        M3_GEM5_OUT=$out M3_CORES=7 M3_RCTMUX_ARGS="0 $3" run $1 $2 alone
    else
        M3_GEM5_OUT=$out M3_CORES=6 M3_RCTMUX_ARGS="1 $3" run $1 $2 shared
    fi
}

jobs_init $2

./b

ds=$((512 * 1024))
wr=/bin/rctmux-util-pipewr
rd=/bin/rctmux-util-piperd

for type in alone shared; do
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
