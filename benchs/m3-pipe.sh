#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/rctmux-pipe.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img

# export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_DBG=Dtu,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=8

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    jobs_started

    /bin/echo -e "\e[1mStarting m3-pipe-$3\e[0m"

    export M3_GEM5_OUT=$1/m3-pipe-$3
    mkdir -p $M3_GEM5_OUT

    export M3_RCTMUX_ARGS="$4"

    if [ "$2" = "a" ]; then
        export M3_GEM5_CFG=config/spm.py
    elif [ "$2" = "b" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=0 M3_GEM5_DTUPOS=0
    else
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
    fi

    ./b run $cfg -n 1>$M3_GEM5_OUT/output.txt 2>&1

    if [ "`grep "Time: " $M3_GEM5_OUT/output.txt | wc -l`" = "8" ]; then
        /bin/echo -e "\e[1mFinished m3-pipe-$3:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-pipe-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

ds=$((32 * 1024 * 1024))
comp=2
wr=/bin/rctmux-util-pipewr
rd=/bin/rctmux-util-piperd

jobs_submit run $1 a a-dram         "0 0 4 3 2 $wr $ds $comp $rd $comp"
jobs_submit run $1 b b-dram         "0 0 4 3 2 $wr $ds $comp $rd $comp"
jobs_submit run $1 c c-dram         "0 0 4 3 2 $wr $ds $comp $rd $comp"
jobs_submit run $1 a a-near-spm     "0 1 4 3 2 $wr $ds $comp $rd $comp"

jobs_wait
