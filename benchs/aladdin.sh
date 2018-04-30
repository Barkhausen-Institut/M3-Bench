#!/bin/bash

. tools/jobs.sh

input=`readlink -f input/aladdin.cfg`

cd m3
export M3_BUILD=release

export M3_FS=bench.img
export M3_GEM5_CFG=config/accels.py
export M3_GEM5_DBG=Aladdin,DtuAccelAladdin,DtuAccelAladdinState,Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
export M3_CORES=5

# export M3_GEM5_CPU=timing

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-aladdin-$2-$3-$4
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-aladdin-$2-$3-$4\e[0m"

    if [ "$4" = "file" ]; then
        export ALADDIN_ARGS="-s $3 -f $2"
    else
        export ALADDIN_ARGS="-s $3 $2"
    fi

    ./b run $input -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-aladdin-$2-$3-$4\e[0m"
}

./b

jobs_init $2

for b in stencil md fft spmv; do
    for s in 1 4 16 64 256 0; do
        jobs_submit run_bench $1 $b $s file
        jobs_submit run_bench $1 $b $s anon
    done
done

jobs_wait
