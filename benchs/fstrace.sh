#!/bin/bash

. tools/fstrace-helper.sh
. tools/jobs.sh

# build M3
export M3_BUILD=bench M3_FS=bench.img M3_CORES=5 M3_GEM5_CFG=config/caches.py
( cd m3 && ./b )
[ $? -eq 0 ] || exit 1

# build Linux
( cd xtensa-linux && ./b mklx && ./b mkapps && ./b mkbr )
[ $? -eq 0 ] || exit 1

run_lx_bench() {
    jobs_started

    /bin/echo -e "\e[1mStarted lx-$2\e[0m"

    mkdir -p $1/lx-fstrace-$2

    export BENCH_CMD=$3 GEM5_OUT=$1/lx-fstrace-$2 GEM5_CP=1

    # run linux benchmark
    ( cd xtensa-linux && ./b fsbench ) > $1/lx-fstrace-$2-output.txt 2>&1

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;31mFAILED\e[0m"
    fi

    # split result into strace and timings
    gen_timedtrace $1/lx-fstrace-$2/res.txt >> $1/lx-fstrace-$2-output.txt 2>&1
}

run_m3_bench() {
    /bin/echo -e "\e[1mStarting m3-$2\e[0m"

    cd m3

    # generate trace.c
    ./build/$M3_TARGET-$LX_ARCH-$M3_BUILD/src/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2/res.txt-timedstrace \
        > $1/lx-fstrace-$2/res.txt-opcodes.c 2>/dev/null
    cp $1/lx-fstrace-$2/res.txt-opcodes.c src/apps/fstrace/m3fs/trace.c

    ./b >/dev/null 2>/dev/null
    [ $? -eq 0 ] || ( jobs_started && exit 1 )

    # run M3 benchmark
    mkdir -p $1/m3-fstrace-$2
    M3_GEM5_OUT=$1/m3-fstrace-$2 ./b run boot/fstrace.cfg -n 1>$1/m3-fstrace-$2-output.txt 2>&1 &

    # wait until gem5 has started the simulation
    while [ "`grep 'info: Entering event queue' $1/m3-fstrace-$2-output.txt`" = "" ]; do
        sleep 1
    done

    jobs_started

    /bin/echo -e "\e[1mStarted m3-$2\e[0m"

    wait

    cd - >/dev/null

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished m3-$2:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-$2:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init $2

jobs_submit run_lx_bench $1 find    "find /bench/finddata/dir -name test"
jobs_submit run_lx_bench $1 tar     "tar -cf /tmp/test.tar /bench/tardata/tar-3968"
jobs_submit run_lx_bench $1 untar   "tar -xf /bench/untardata/tar-3968.tar -C /tmp"
jobs_submit run_lx_bench $1 sqlite  "/bench/bin/sqlite /tmp/test.db"

jobs_wait

jobs_submit run_m3_bench $1 find
jobs_submit run_m3_bench $1 tar
jobs_submit run_m3_bench $1 untar
jobs_submit run_m3_bench $1 sqlite

jobs_wait

# BENCH_CMD="find /finddata/dir-160 -name test" run_bench $1 find

# BENCH_CMD="find /finddata/dir-320-multi -name test" run_bench $1 find

# BENCH_CMD="wc /large.txt" run_bench $1 wc

# BENCH_CMD="grep -rn test /finddata/dir-40 /largetext.txt" run_bench $1 grep

# BENCH_CMD="sha256sum /largetext.txt" run_bench $1 sha256sum

# BENCH_CMD="sort -o /tmp/sorted.txt /largetext.txt" run_bench $1 sort

# BENCH_CMD="tail /largetext.txt" run_bench $1 tail
