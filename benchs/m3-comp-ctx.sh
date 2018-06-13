#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/rctmux.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector,DtuMsgs
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    jobs_started

    /bin/echo -e "\e[1mStarting m3-comp-ctx-$2-$3-$4\e[0m"

    export M3_GEM5_OUT=$1/m3-comp-ctx-$2-$3-$4
    mkdir -p $M3_GEM5_OUT

    export M3_KERNEL_ARGS="-t=$(($4 * 3000000))"
    COMP_CYCLES=60000000
    if [ "$2" = "alone" ]; then
        export M3_CORES=6 M3_RCTMUX_ARGS="0 4 2 /bin/rctmux-util-compute $COMP_CYCLES /bin/rctmux-util-compute $COMP_CYCLES"
    else
        export M3_CORES=5 M3_RCTMUX_ARGS="1 4 2 /bin/rctmux-util-compute $COMP_CYCLES /bin/rctmux-util-compute $COMP_CYCLES"
    fi

    if [ "$3" = "c" ]; then
        export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
    else
        export M3_GEM5_MMU=0
    fi

    ./b run $cfg -n 1>$M3_GEM5_OUT/output.txt 2>&1

    if [ $? -eq 0 ] && [ "`grep 'Time: ' $M3_GEM5_OUT/output.txt | wc -l`" = "4" ]; then
        /bin/echo -e "\e[1mFinished m3-comp-ctx-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-comp-ctx-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

jobs_submit run $1 alone c 1
for ts in 1 2 4 8; do
    jobs_submit run $1 shared c $ts
done

jobs_wait
