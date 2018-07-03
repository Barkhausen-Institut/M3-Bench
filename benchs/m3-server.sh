#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-server.cfg`

cd m3

export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-server-$2-$3-$4-$5
    mkdir -p $M3_GEM5_OUT

    export M3_SCALE_ARGS="$2 $5 1 1 $3 $4 `stat --format="%s" build/$M3_TARGET-x86_64-$M3_BUILD/$M3_FS`"
    export M3_GEM5_FSNUM=$4

    if [ "$m" = "0" ]; then
        export M3_CORES=52
    else
        export M3_CORES=$((12 + $3))
    fi

    /bin/echo -e "\e[1mStarted m3-server-$2-$3-$4-$5\e[0m"

    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ "`grep "^/bin/fstrace-m3fs exited with 0" $M3_GEM5_OUT/output.txt | wc -l`" = "$3" ]; then
        /bin/echo -e "\e[1mFinished m3-server-$2-$3-$4-$5:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-server-$2-$3-$4-$5:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for m in 0 1; do
    jobs_submit run $1 nginx 1 1 $m
    jobs_submit run $1 nginx 2 1 $m
    jobs_submit run $1 nginx 4 1 $m
    jobs_submit run $1 nginx 4 2 $m
    jobs_submit run $1 nginx 8 1 $m
    jobs_submit run $1 nginx 8 2 $m
    jobs_submit run $1 nginx 8 4 $m
    jobs_submit run $1 nginx 16 1 $m
    jobs_submit run $1 nginx 16 2 $m
    jobs_submit run $1 nginx 16 4 $m
    jobs_submit run $1 nginx 32 2 $m
    jobs_submit run $1 nginx 32 4 $m
    jobs_submit run $1 nginx 32 8 $m
done

jobs_wait
