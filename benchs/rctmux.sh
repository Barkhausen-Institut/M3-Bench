#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/rctmux.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector,DtuMsgs
# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    /bin/echo -e "\e[1mStarting $2-$3\e[0m"

    ./b run $cfg -n 1>>$M3_GEM5_OUT/output.txt 2>&1 &

    # wait until gem5 has started the simulation
    while [ "`grep 'info: Entering event queue' $M3_GEM5_OUT/output.txt`" = "" ]; do
        sleep 1
    done

    # now, other jobs can be started (and change the build dir)
    jobs_started

    /bin/echo -e "\e[1mStarted $2-$3\e[0m"

    wait

    if [ $? -eq 0 ] && [ "`grep 'benchmark terminated' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

run_fstrace() {
    out=$1/m3-rctmux-$2-$3
    mkdir -p $out

    /bin/echo -e "\e[1mBuilding $2-$3\e[0m"

    # rebuild it first
    cp ../input/trace-$2.c src/apps/fstrace/m3fs/trace.c
    ./b 1>$out/output.txt
    if [ $? -ne 0 ]; then
        /bin/echo -e "\e[1;31mBuild failed\e[0m"
        exit
    fi

    if [ "$3" = "alone" ]; then
        M3_GEM5_OUT=$out M3_CORES=6 M3_RCTMUX_ARGS="0 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" run $1 $2 $3
    else
        M3_GEM5_OUT=$out M3_CORES=5 M3_RCTMUX_ARGS="1 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" run $1 $2 $3
    fi
}

jobs_init $2

jobs_submit run_fstrace $1 tar alone
jobs_submit run_fstrace $1 tar shared
jobs_submit run_fstrace $1 untar alone
jobs_submit run_fstrace $1 untar shared
jobs_submit run_fstrace $1 find alone
jobs_submit run_fstrace $1 find shared
jobs_submit run_fstrace $1 sqlite alone
jobs_submit run_fstrace $1 sqlite shared

jobs_wait
