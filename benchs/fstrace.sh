#!/bin/bash

source tools/fstrace-helper.sh

cd xtensa-linux

./b mklx
./b mkapps
./b mkbr

cd -

run_bench() {
    mkdir -p $1/lx-fstrace-$2

    # run linux benchmark
    ( cd xtensa-linux && GEM5_OUT=$1/lx-fstrace-$2 GEM5_CP=1 ./b fsbench )

    # split result into strace and timings
    gen_timedtrace $1/lx-fstrace-$2/res.txt

    cd m3

    export M3_BUILD=bench M3_FS=bench.img M3_CORES=5 M3_GEM5_CFG=config/caches.py

    ./b

    # generate trace.c
    ./build/$M3_TARGET-$LX_ARCH-$M3_BUILD/src/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2/res.txt-timedstrace \
        > $1/lx-fstrace-$2/res.txt-opcodes.c
    cp $1/lx-fstrace-$2/res.txt-opcodes.c src/apps/fstrace/m3fs/trace.c

    # run M3 benchmark
    mkdir -p $1/m3-fstrace-$2
    M3_GEM5_OUT=$1/m3-fstrace-$2 ./b run boot/fstrace.cfg

    cd -
}

BENCH_CMD="find /bench/finddata/dir -name test" run_bench $1 find

# BENCH_CMD="find /finddata/dir-160 -name test" run_bench $1 find

# BENCH_CMD="find /finddata/dir-320-multi -name test" run_bench $1 find

BENCH_CMD="tar -cf /tmp/test.tar /bench/tardata/tar-3968" run_bench $1 tar

BENCH_CMD="tar -xf /bench/untardata/tar-3968.tar -C /tmp" run_bench $1 untar

BENCH_CMD="/bench/bin/sqlite /tmp/test.db" run_bench $1 sqlite

# BENCH_CMD="wc /large.txt" run_bench $1 wc

# BENCH_CMD="grep -rn test /finddata/dir-40 /largetext.txt" run_bench $1 grep

# BENCH_CMD="sha256sum /largetext.txt" run_bench $1 sha256sum

# BENCH_CMD="sort -o /tmp/sorted.txt /largetext.txt" run_bench $1 sort

# BENCH_CMD="tail /largetext.txt" run_bench $1 tail
