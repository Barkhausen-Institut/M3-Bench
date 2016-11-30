#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/rctmux.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

run() {
    /bin/echo -e "\e[1mStarting $2-$3\e[0m"

    echo > $1/m3-rctmux-$2-$3-output.txt

    ./b run $cfg -n 1>$1/m3-rctmux-$2-$3-output.txt 2>&1 &

    # wait until gem5 has started the simulation
    while [ "`grep 'info: Entering event queue' $1/m3-rctmux-$2-$3-output.txt`" = "" ]; do
        sleep 1
    done

    # now, other jobs can be started (and change the build dir)
    jobs_started

    /bin/echo -e "\e[1mStarted $2-$3\e[0m"

    wait

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
        ./src/tools/bench.sh $M3_GEM5_OUT/gem5.log > $1/m3-rctmux-$2-$3.txt
        mv $M3_GEM5_OUT/gem5.log $1/m3-rctmux-$2-$3.log
    else
        /bin/echo -e "\e[1mFinished $2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

run_fstrace() {
    # rebuild it first
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c src/apps/fstrace/m3fs/trace.c
    ./b 1>/dev/null 2>/dev/null

    out=`mktemp -d`

    if [ "$3" = "alone" ]; then
        M3_GEM5_OUT=$out M3_CORES=6 M3_RCTMUX_ARGS="0 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" run $1 $2 $3
    else
        M3_GEM5_OUT=$out M3_CORES=5 M3_RCTMUX_ARGS="1 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" run $1 $2 $3
    fi

    rm -rf $out
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
