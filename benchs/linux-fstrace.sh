#!/bin/bash

. tools/helper.sh
. tools/jobs.sh

# build Linux
export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
( cd xtensa-linux && ./b mklx && ./b mkapps && ./b mkbenchfs )
[ $? -eq 0 ] || exit 1

run_lx_bench() {
    jobs_started

    /bin/echo -e "\e[1mStarted lx-$2\e[0m"

    mkdir -p $1/lx-fstrace-$2

    export BENCH_CMD=$3 GEM5_OUT=$1/lx-fstrace-$2 GEM5_CP=1
    if [[ $2 == *-5 ]]; then
        export GEM5_L1LAT=5
    fi

    # run linux benchmark
    ( cd xtensa-linux && ./b fsbench ) > $GEM5_OUT/output.txt 2>&1

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;31mFAILED\e[0m"
    fi

    # split result into strace and timings
    gen_timedtrace $1/lx-fstrace-$2/res.txt 3 >> $GEM5_OUT/output.txt 2>&1

    # generate trace.c
    ( cd m3 && M3_BUILD=release ./b )
    ./m3/build/$M3_TARGET-$LX_ARCH-release/src/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2/res.txt-timedstrace \
        > $1/lx-fstrace-$2/res.txt-opcodes.c 2>/dev/null
    cp $1/lx-fstrace-$2/res.txt-opcodes.c input/trace-$2.c
}

jobs_init $2

jobs_submit run_lx_bench $1 find    "find /bench/finddata/dir -name test"
jobs_submit run_lx_bench $1 tar     "tar -cf /tmp/test.tar /bench/tardata/tar-16m"
jobs_submit run_lx_bench $1 untar   "tar -xf /bench/untardata/tar-16m.tar -C /tmp"
jobs_submit run_lx_bench $1 sqlite  "/bench/bin/sqlite /tmp/test.db"
jobs_submit run_lx_bench $1 leveldb "/bench/bin/leveldb /tmp/test.db"
jobs_submit run_lx_bench $1 tar-small     "tar -cf /tmp/test.tar /bench/finddata/dir-80"
jobs_submit run_lx_bench $1 untar-small   "tar -xf /bench/untardata/tar-small.tar -C /tmp"
jobs_submit run_lx_bench $1 sha256sum "sha256sum /bench/www/512k.txt"
jobs_submit run_lx_bench $1 sort      "sort -o /tmp/sorted.txt /bench/unsorted.txt"

jobs_wait

# BENCH_CMD="find /finddata/dir-160 -name test" run_bench $1 find

# BENCH_CMD="find /finddata/dir-320-multi -name test" run_bench $1 find

# BENCH_CMD="wc /large.txt" run_bench $1 wc

# BENCH_CMD="grep -rn test /finddata/dir-40 /largetext.txt" run_bench $1 grep

# BENCH_CMD="sha256sum /largetext.txt" run_bench $1 sha256sum

# BENCH_CMD="sort -o /tmp/sorted.txt /largetext.txt" run_bench $1 sort

# BENCH_CMD="tail /largetext.txt" run_bench $1 tail
