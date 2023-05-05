#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-pagefaults.cfg`

cd m3
export M3_BUILD=release

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_LOG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=6

# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-pagefaults-$2-$3-$4-$5 M3_GEM5_MMU=$2 M3_GEM5_DTUPOS=$3
    export M3_PAGER_MAX_ANON=$5 M3_PAGER_MAX_EXTERN=$5 M3_BENCH_ARG=$4
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-pagefaults-$2-$3-$4-$5\e[0m"

    ./b run $cfg -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-pagefaults-$2-$3-$4-$5\e[0m"
}

./b || exit 1

jobs_init $2

for map in anon file; do
    for pages in 1 4; do
        jobs_submit run_bench $1 0 0 $map $pages
        jobs_submit run_bench $1 1 0 $map $pages
        jobs_submit run_bench $1 1 2 $map $pages
    done
done

jobs_wait
