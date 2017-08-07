#!/bin/bash

. tools/jobs.sh

config=`readlink -f input/config-lowpass-filter.py`
script=`readlink -f input/lowpass-filter.cfg`

cd m3
export M3_BUILD=bench

export M3_GEM5_CFG=$config
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_MEMFREQ=1GHz
export M3_CORES=6
# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-lowpass-filter-$2 M3_FS=bench.img
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-lowpass-filter-$2\e[0m"

    export LP_DIRECT=$2

    ./b run $script -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-lowpass-filter-$2\e[0m"
}

./b

jobs_init $2

jobs_submit run_bench $1 0
jobs_submit run_bench $1 1

jobs_wait
