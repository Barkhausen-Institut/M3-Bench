#!/bin/bash

cfg=`readlink -f input/fstrace.cfg`

. tools/helper.sh
. tools/jobs.sh

cd m3

export M3_FSBPE=128
export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuXfers,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=5 M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2

# export M3_GEM5_CPU=TimingSimpleCPU

run_m3_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-fstrace-$2
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-$2\e[0m"

    export FSTRACE_ARGS="-n 4 $2"
    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ $? -eq 0 ] && [ "`grep 'benchmark terminated' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-$2:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-$2:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

jobs_submit run_m3_bench $1 find
jobs_submit run_m3_bench $1 tar
jobs_submit run_m3_bench $1 untar
jobs_submit run_m3_bench $1 sqlite
jobs_submit run_m3_bench $1 leveldb
jobs_submit run_m3_bench $1 sha256sum
jobs_submit run_m3_bench $1 sort

jobs_wait

# BENCH_CMD="find /finddata/dir-160 -name test" run_bench $1 find

# BENCH_CMD="find /finddata/dir-320-multi -name test" run_bench $1 find

# BENCH_CMD="wc /large.txt" run_bench $1 wc

# BENCH_CMD="grep -rn test /finddata/dir-40 /largetext.txt" run_bench $1 grep

# BENCH_CMD="sha256sum /largetext.txt" run_bench $1 sha256sum

# BENCH_CMD="sort -o /tmp/sorted.txt /largetext.txt" run_bench $1 sort

# BENCH_CMD="tail /largetext.txt" run_bench $1 tail
