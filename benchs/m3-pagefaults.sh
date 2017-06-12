#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-pagefaults.cfg`

cd m3
export M3_BUILD=bench

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_PAGER_MAX_ANON=8 M3_PAGER_MAX_EXTERN=8
export M3_CORES=5
# export M3_GEM5_CPU=timing

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-pagefaults-$2-$3 M3_GEM5_MMU=$2 M3_GEM5_DTUPOS=$3
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-pagefaults-$2-$3\e[0m"

    ./b run $cfg -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-pagefaults-$2-$3\e[0m"
}

./b

jobs_init $2

for mmu in 0 1; do
    for dtupos in 0 1 2; do
        if [ $mmu -eq 1 ] || [ $dtupos == 0 ]; then
            jobs_submit run_bench $1 $mmu $dtupos
        fi
    done
done

jobs_wait
