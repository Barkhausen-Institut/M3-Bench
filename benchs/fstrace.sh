#!/bin/bash

cfg=`readlink -f input/fstrace.cfg`

. tools/helper.sh
. tools/jobs.sh

# build M3
export M3_BUILD=bench M3_FS=bench.img M3_CORES=5 M3_GEM5_CFG=config/caches.py
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
( cd m3 && ./b )
[ $? -eq 0 ] || exit 1

# build Linux
export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
( cd xtensa-linux && ./b mklx && ./b mkapps && ./b mkbr )
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
    gen_timedtrace $1/lx-fstrace-$2/res.txt >> $GEM5_OUT/output.txt 2>&1
}

run_m3_bench() {
    /bin/echo -e "\e[1mStarting m3-$2-$3-$4\e[0m"

    cd m3

    # generate trace.c
    ./build/$M3_TARGET-$LX_ARCH-$M3_BUILD/src/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2/res.txt-timedstrace \
        > $1/lx-fstrace-$2/res.txt-opcodes.c 2>/dev/null
    cp $1/lx-fstrace-$2/res.txt-opcodes.c src/apps/fstrace/m3fs/trace.c

    ./b >/dev/null 2>/dev/null
    [ $? -eq 0 ] || ( jobs_started && exit 1 )

    # run M3 benchmark
    export M3_GEM5_OUT=$1/m3-fstrace-$2-$3-$4 M3_GEM5_MMU=$3 M3_GEM5_DTUPOS=$4
    mkdir -p $M3_GEM5_OUT
    ./b run $cfg -n 1>$M3_GEM5_OUT/output.txt 2>&1 &

    # wait until gem5 has started the simulation
    while [ "`grep 'info: Entering event queue' $M3_GEM5_OUT/output.txt`" = "" ]; do
        sleep 1
    done

    jobs_started

    /bin/echo -e "\e[1mStarted m3-$2-$3-$4\e[0m"

    wait

    cd - >/dev/null

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished m3-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init $2

jobs_submit run_lx_bench $1 find    "find /bench/finddata/dir -name test"
jobs_submit run_lx_bench $1 tar     "tar -cf /tmp/test.tar /bench/tardata/tar-3968"
jobs_submit run_lx_bench $1 untar   "tar -xf /bench/untardata/tar-3968.tar -C /tmp"
jobs_submit run_lx_bench $1 sqlite  "/bench/bin/sqlite /tmp/test.db"

# 1 cycle more latency for address translation in the DTU
jobs_submit run_lx_bench $1 find-5    "find /bench/finddata/dir -name test"
jobs_submit run_lx_bench $1 tar-5     "tar -cf /tmp/test.tar /bench/tardata/tar-3968"
jobs_submit run_lx_bench $1 untar-5   "tar -xf /bench/untardata/tar-3968.tar -C /tmp"
jobs_submit run_lx_bench $1 sqlite-5  "/bench/bin/sqlite /tmp/test.db"

jobs_wait

# use the 5 cycles waittimes, but compare later on it with the 4 cycles run of Linux
jobs_submit run_m3_bench $1 find-5 0 0
jobs_submit run_m3_bench $1 tar-5 0 0
jobs_submit run_m3_bench $1 untar-5 0 0
jobs_submit run_m3_bench $1 sqlite-5 0 0

for dtupos in 0 1 2; do
    jobs_submit run_m3_bench $1 find $mmu $dtupos
    jobs_submit run_m3_bench $1 tar $mmu $dtupos
    jobs_submit run_m3_bench $1 untar $mmu $dtupos
    jobs_submit run_m3_bench $1 sqlite $mmu $dtupos
done

jobs_wait

# BENCH_CMD="find /finddata/dir-160 -name test" run_bench $1 find

# BENCH_CMD="find /finddata/dir-320-multi -name test" run_bench $1 find

# BENCH_CMD="wc /large.txt" run_bench $1 wc

# BENCH_CMD="grep -rn test /finddata/dir-40 /largetext.txt" run_bench $1 grep

# BENCH_CMD="sha256sum /largetext.txt" run_bench $1 sha256sum

# BENCH_CMD="sort -o /tmp/sorted.txt /largetext.txt" run_bench $1 sort

# BENCH_CMD="tail /largetext.txt" run_bench $1 tail
