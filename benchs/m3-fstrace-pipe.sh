#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-scale-pipe.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_LOG=Dtu,DtuRegWrite,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
export M3_CORES=11

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    export M3_GEM5_OUT=$1/m3-fstrace-pipe-$2-$3
    mkdir -p $M3_GEM5_OUT

    export M3_SCALE_ARGS="-i 1 -r 4 $2_$3_$2 $2_$3_$3"

    /bin/echo -e "\e[1mStarted m3-fstrace-pipe-$2-$3\e[0m"
    jobs_started

    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ "`grep --text "Time: " $M3_GEM5_OUT/output.txt | wc -l`" = "4" ]; then
        /bin/echo -e "\e[1mFinished m3-fstrace-pipe-$2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-fstrace-pipe-$2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

jobs_submit run $1 cat awk
jobs_submit run $1 cat wc
jobs_submit run $1 grep awk
jobs_submit run $1 grep wc

jobs_wait
