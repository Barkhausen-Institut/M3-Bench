#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-tlbmiss.cfg`

cd m3
export M3_BUILD=bench

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector,DtuPf,Exec
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=2

# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-tlbmiss-$2-$3 M3_GEM5_MMU=$2 M3_GEM5_DTUPOS=$3
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-tlbmiss-$2-$3\e[0m"

    ./b run $cfg -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-tlbmiss-$2-$3\e[0m"
}

./b

jobs_init $2

jobs_submit run_bench $1 0 0
jobs_submit run_bench $1 1 0
jobs_submit run_bench $1 1 2

jobs_wait
