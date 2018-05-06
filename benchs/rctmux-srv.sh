#!/bin/sh

. tools/jobs.sh

cfg=`readlink -f input/rctmux-srv.cfg`

cd m3
export M3_BUILD=release

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
# export M3_GEM5_CPU=TimingSimpleCPU

export M3_GEM5_CFG=config/caches.py

run() {
    jobs_started

    /bin/echo -e "\e[1mStarting m3-ctx-srv-$2-$3\e[0m"

    export M3_GEM5_OUT=$1/m3-ctx-srv-$2-$3
    mkdir -p $M3_GEM5_OUT

    if [ "$3" = "c" ]; then
        export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
    else
        export M3_GEM5_MMU=0
    fi

    export RCTMUX_ARGS="$4"
    if [ "$2" = "alone" ]; then
        export M3_CORES=7
    elif [ "$2" = "sh-srv" ]; then
        export M3_CORES=6
    else
        export M3_CORES=5
    fi

    ./b run $cfg -n 1>$M3_GEM5_OUT/output.txt 2>&1

    if [ "`grep 'Time: ' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-ctx-srv-$2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-ctx-srv-$2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init $2

./b

for t in b c; do
    jobs_submit run $1 alone $t "0"
    jobs_submit run $1 sh-srv $t "1"
    jobs_submit run $1 sh-all $t "2"
done

jobs_wait
