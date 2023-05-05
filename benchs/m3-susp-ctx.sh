#!/bin/bash

. tools/jobs.sh

boot_c=`readlink -f input/rctmux-srv.cfg`
cfg_a=`readlink -f input/config-accelchain.py`
cfg_b=`readlink -f input/config-aladdin.py`

cd m3
export M3_BUILD=release

export M3_GEM5_LOG=DtuAccelStream,DtuAccelStreamState,DtuAccelAladdin,DtuAccelAladdinState,Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    jobs_started

    /bin/echo -e "\e[1mStarting m3-ctx-susp-$2-$3\e[0m"

    export M3_GEM5_OUT=$1/m3-ctx-susp-$2-$3
    mkdir -p $M3_GEM5_OUT

    if [ "$2" = "c" ]; then
        export RCTMUX_ARGS="$4"
        if [ "$3" = "alone" ]; then
            export M3_CORES=7
        elif [ "$3" = "sh-srv" ]; then
            export M3_CORES=6
        else
            export M3_CORES=5
        fi
        export M3_GEM5_CFG=config/caches.py
        boot=$boot_c
    else
        if [ "$3" = "alone" ]; then
            export M3_CORES=4 ACCEL_NUM=2
        else
            export M3_CORES=4 ACCEL_NUM=1
        fi
        if [ "$2" = "a" ]; then
            export M3_GEM5_CFG=$cfg_a
            boot=boot/rctmux-streamtest.cfg
        else
            export M3_GEM5_CFG=$cfg_b
            boot=boot/rctmux-aladdin.cfg
        fi
    fi

    ./b run $boot -n 1>$M3_GEM5_OUT/output.txt 2>&1

    if [ "`grep 'Time: ' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-ctx-susp-$2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-ctx-susp-$2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

jobs_submit run $1 a alone
jobs_submit run $1 a shared

jobs_submit run $1 b alone
jobs_submit run $1 b shared

jobs_submit run $1 c alone "0"
jobs_submit run $1 c sh-srv "1"
jobs_submit run $1 c sh-all "2"

jobs_wait
