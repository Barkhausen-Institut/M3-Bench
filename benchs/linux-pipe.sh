#!/bin/bash

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5`

. tools/jobs.sh

cd xtensa-linux

./b mkapps
./b mklx
./b mkbr

export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
export GEM5_FLAGS=Dtu

run() {
    /bin/echo -e "\e[1mStarting lx-pipe\e[0m"

    jobs_started

    export GEM5_OUT=$1/lx-pipe
    mkdir -p $GEM5_OUT

    BENCH_CMD="$2" GEM5_CP=1 LX_CORES=2 ./b bench 1>/dev/null 2>/dev/null

    if [ "`grep "^total : " $GEM5_OUT/res.txt | wc -l`" = "8" ]; then
        /bin/echo -e "\e[1mFinished lx-pipe:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-pipe:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init $2

datasize=$((32 * 1024 * 1024))
comp=2
wr=/bench/bin/pipewr
rd=/bench/bin/piperd

jobs_submit run $1 "/bench/bin/execpipe 3 2 8 1 1 0 $wr $datasize $comp $rd $comp"

jobs_wait
