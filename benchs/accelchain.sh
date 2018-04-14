#!/bin/bash

. tools/jobs.sh

script=`readlink -f input/accelchain.cfg`
config=`readlink -f input/config-accelchain.py`

cd m3
export M3_BUILD=release

export M3_GEM5_CFG=$config
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector,DtuAccelStream,DtuAccelStreamState
export M3_GEM5_MEMFREQ=1GHz
export M3_CORES=6
# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-accelchain-$2-$3-$4 M3_FS=bench.img
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-accelchain-$2-$3-$4\e[0m"

    export ACCEL_DIRECT=$2 ACCEL_COMPTIME=$3 ACCEL_NUM=$4

    ./b run $script -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    if [ "`grep 'Total time:' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-accelchain-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-accelchain-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b

jobs_init $2

for num in 1 2 3 4 5 6; do
    for time in 1024 2048 4096 8192 16384 32768; do
        jobs_submit run_bench $1 0 $time $num
        jobs_submit run_bench $1 1 $time $num
        jobs_submit run_bench $1 2 $time $num
    done
done

jobs_wait
