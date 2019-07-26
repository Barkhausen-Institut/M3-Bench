#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-scale-pipe.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_DBG=DtuMsgs,DtuSysCalls,Dtu,DtuRegWrite,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    export M3_GEM5_OUT=$1/m3-fstrace-pipe-$2-$3-$4
    mkdir -p $M3_GEM5_OUT

    export M3_SCALE_ARGS="-m -i 1 -r 4 $2_$3_$2 $2_$3_$3"

    if [ "$4" = "1" ]; then
        export M3_CORES=8
    elif [ "$4" = "2" ]; then
        export M3_CORES=9
    else
        export M3_CORES=12
    fi

    /bin/echo -e "\e[1mStarted m3-fstrace-pipe-$2-$3-$4\e[0m"
    jobs_started

    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ "`grep --text "Time: " $M3_GEM5_OUT/output.txt | wc -l`" = "4" ]; then
        /bin/echo -e "\e[1mFinished m3-fstrace-pipe-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-fstrace-pipe-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for m in 0 1 2; do
    jobs_submit run $1 cat awk $m
    jobs_submit run $1 cat wc $m
    jobs_submit run $1 grep awk $m
    jobs_submit run $1 grep wc $m
done

jobs_wait
