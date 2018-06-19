#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-scale-pipe.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    export M3_GEM5_OUT=$1/m3-scale-pipe-$2-$3-$4-$5
    mkdir -p $M3_GEM5_OUT

    export M3_SCALE_ARGS="$2_$3_$2 $2_$3_$3 1 0 $5 $4"

    if [ "$5" = "1" ]; then
        export M3_CORES=$(($4 * 2 + 4))
    else
        export M3_CORES=$(($4 * 2 + 7))
    fi

    /bin/echo -e "\e[1mStarted m3-scale-pipe-$2-$3-$4-$5\e[0m"
    jobs_started

    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ "`grep --text "/bin/fstrace-m3fs exited with 0" $M3_GEM5_OUT/output.txt | wc -l`" = "$(($4 * 2))" ]; then
        /bin/echo -e "\e[1mFinished m3-scale-pipe-$2-$3-$4-$5:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-scale-pipe-$2-$3-$4-$5:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for muxed in 0 1; do
    for n in 1 2 4 8 16; do
        jobs_submit run $1 cat awk $n $muxed
        jobs_submit run $1 cat wc $n $muxed
        jobs_submit run $1 grep awk $n $muxed
        jobs_submit run $1 grep wc $n $muxed
    done
done

jobs_wait
