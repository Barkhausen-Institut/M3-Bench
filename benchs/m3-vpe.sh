#!/bin/bash

. tools/jobs.sh

cd m3
export M3_BUILD=release

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=6

# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    if [ $2 -eq 2 ]; then
        export M3_GEM5_CFG=config/spm.py
    else
        export M3_GEM5_CFG=config/caches.py
    fi

    cfg=`readlink -f ../input/bench-vpe-$5.cfg`

    export M3_GEM5_OUT=$1/m3-vpe-$5-$2-$3-$4 M3_GEM5_MMU=$2 M3_GEM5_DTUPOS=$3
    export M3_BENCH_ARG=$4
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-vpe-$5-$2-$3-$4\e[0m"

    ./b run $cfg -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    if [ "`grep "Time for $5: " $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-vpe-$5-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-vpe-$5-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b

jobs_init $2

for b in clone exec; do
    for size in $((1)) $((1024 * 2048)) $((1024 * 4096)) $((1024 * 8192)); do
        jobs_submit run_bench $1 2 0 $size $b
        jobs_submit run_bench $1 0 0 $size $b
        jobs_submit run_bench $1 1 0 $size $b
        jobs_submit run_bench $1 1 2 $size $b
    done
done

jobs_wait
