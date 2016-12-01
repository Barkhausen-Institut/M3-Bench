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
        mv $M3_GEM5_OUT/gem5.log $1/m3-rctmux-$2-$3.log
    else
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

run_pipe() {
    jobs_started

    out=`mktemp -d`
    if [ "$4" = "alone" ]; then
        M3_GEM5_OUT=$out M3_CORES=7 M3_RCTMUX_ARGS="0 $3" run $1 $2 alone
    else
        M3_GEM5_OUT=$out M3_CORES=6 M3_RCTMUX_ARGS="1 $3" run $1 $2 shared
    fi
    rm -rf $out
}

run_pipe_m3fs() {
    jobs_started

    out=`mktemp -d`
    if [ "$4" = "alone" ]; then
        M3_GEM5_OUT=$out M3_CORES=8 M3_RCTMUX_ARGS="2 $3" run $1 $2 m3fs-alone
    else
        M3_GEM5_OUT=$out M3_CORES=7 M3_RCTMUX_ARGS="3 $3" run $1 $2 m3fs-shared
    fi
    rm -rf $out
}

jobs_init $2

./b

for type in alone shared; do
    for size in 64 128 256 512 1024; do
        jobs_submit run_pipe $1 rand-wc-${size}k        "2 1 /bin/rand $(($size * 1024)) /bin/wc" $type
        jobs_submit run_pipe $1 cat-wc-${size}k         "2 1 /bin/cat /data/${size}k.txt /bin/wc" $type
        jobs_submit run_pipe $1 rand-sink-${size}k      "2 1 /bin/rand $(($size * 1024)) /bin/sink" $type
        jobs_submit run_pipe $1 cat-sink-${size}k       "2 1 /bin/cat /data/${size}k.txt /bin/sink" $type

        f="/foo/data/$(($size / 4))k.txt"
        jobs_submit run_pipe_m3fs $1 cat-wc-${size}k    "5 1 /bin/cat $f $f $f $f /bin/wc" $type
    done
done

jobs_wait
