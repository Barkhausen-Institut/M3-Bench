#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-scale.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    export M3_GEM5_OUT=$1/m3-fstrace-ctx-$2-$3-$4
    mkdir -p $M3_GEM5_OUT

    if [ "$4" = "1" ]; then
        export M3_CORES=7
    elif [ "$4" = "2" ]; then
        export M3_CORES=8
    else
        export M3_CORES=10
    fi

    /bin/echo -e "\e[1mStarted m3-fstrace-ctx-$2-$3-$4\e[0m"
    jobs_started

    export M3_SCALE_ARGS="-m -r 4 $2 `stat --format="%s" build/$M3_TARGET-x86_64-$M3_BUILD/$M3_FS`"

    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ "`grep "^/bin/fstrace-m3fs exited with 0" $M3_GEM5_OUT/output.txt | wc -l`" = "$3" ]; then
        /bin/echo -e "\e[1mFinished m3-fstrace-ctx-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-fstrace-ctx-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for t in tar untar find sqlite leveldb sha256sum sort; do
    jobs_submit run $1 $t 1 0
    jobs_submit run $1 $t 1 1
    jobs_submit run $1 $t 1 2
done

jobs_wait
