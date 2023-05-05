#!/bin/bash

. tools/jobs.sh

script=`readlink -f input/accelchain.cfg`
config=`readlink -f input/config-accelchain.py`

cd m3
export M3_BUILD=release

export M3_GEM5_CFG=$config
export M3_GEM5_LOG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
#,DtuAccelStream,DtuAccelStreamState
export M3_GEM5_CPUFREQ=3GHz
export M3_GEM5_MEMFREQ=1GHz
export M3_CORES=8
# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-accelchain-ctx-$2-$4-$5 M3_FS=bench.img
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-accelchain-ctx-$2-$4-$5\e[0m"

    export ACCEL_DIRECT=$2 ACCEL_COMPTIME=$3 ACCEL_NUM=$4 ACCEL_REPEATS=4
    export M3_KERNEL_ARGS="-t=$(($5 * 3000000))"

    ./b run $script -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    if [ "`grep 'Total time:' $M3_GEM5_OUT/output.txt | wc -l`" != "$ACCEL_REPEATS" ]; then
        /bin/echo -e "\e[1mFinished m3-accelchain-ctx-$2-$4-$5:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-accelchain-ctx-$2-$4-$5:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for num in 1 2 4 8; do
    for ts in 1 2 4; do
        jobs_submit run_bench $1 1 1024 $num $ts
        jobs_submit run_bench $1 3 1024 $num $ts
    done
done

jobs_wait
