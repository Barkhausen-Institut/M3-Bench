#!/bin/bash

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5-lx`

. tools/jobs.sh

cd xtensa-linux

./b mkapps
./b mklx
./b mkbenchfs

export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
export GEM5_FLAGS=Dtu

run_bench() {
    jobs_started

    export GEM5_OUT=$1/lx-fs-$2
    mkdir -p $GEM5_OUT

    /bin/echo -e "\e[1mStarted lx-fs-$2\e[0m"

    BENCH_CMD="$3" GEM5_CP=1 ./b bench >/dev/null 2>/dev/null

    /bin/echo -e "\e[1mFinished lx-fs-$2\e[0m"
}

jobs_init $2

jobs_submit run_bench $1 read "/bench/bin/read /bench/large.bin"
jobs_submit run_bench $1 write "/bench/bin/write /tmp/res.bin $((32 * 1024 * 1024))"
jobs_submit run_bench $1 write-notrunc "/bench/bin/write /tmp/res.bin $((32 * 1024 * 1024)) notrunc"
jobs_submit run_bench $1 copy "/bench/bin/cp /bench/large.bin /tmp/res.bin"
jobs_submit run_bench $1 sendfile "/bench/bin/sendfile /bench/large.bin /tmp/res.bin"

jobs_wait
