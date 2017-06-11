#!/bin/bash

source tools/fstrace-helper.sh

cd xtensa-linux

./b mklx
./b mkapps
./b mkbr

cd -

wait_time() {
    echo -n "[$2] Wait: "
    ./tools/timedstrace.php $LX_ARCH waittime $1-strace $1-timings
}

run_bench() {
    cd xtensa-linux

    if [ "$LX_ARCH" = "xtensa" ]; then
        ./b mkbr
        ./b mkdisk
        ./b fsbench > $1/lx-fstrace-$2-xtensa-13cycles.txt
        # better regenerate the filesystem image, in case it is broken
        ./b mkbr
        LX_THCMP=1 ./b fsbench > $1/lx-fstrace-$2-30cycles.txt
    else
        GEM5_OUT=gem5-test GEM5_CP=1 ./b fsbench
        cp gem5-test/res.txt $1/lx-fstrace-$2-30cycles.txt
    fi

    cd -

    if [ "$LX_ARCH" = "xtensa" ]; then
        gen_timedtrace $1/lx-fstrace-$2-13cycles.txt $LX_ARCH
    fi
    gen_timedtrace $1/lx-fstrace-$2-30cycles.txt $LX_ARCH

    cd m3
    export M3_BUILD=bench M3_FS=bench.img M3_CORES=5 M3_GEM5_CFG=config/caches.py

    ./b

    ./build/$M3_TARGET-$LX_ARCH-$M3_BUILD/src/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2-30cycles.txt-timedstrace \
        > $1/lx-fstrace-$2-30cycles.txt-opcodes.c
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c src/apps/fstrace/m3fs/trace.c

    ./b run boot/fstrace.cfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-fstrace.$2-txt

    if [ "$LX_ARCH" = "xtensa" ]; then
        extract_result $1/lx-fstrace-$2-13cycles.txt-timings $2 > $1/lx-fstrace-$2-result-13cycles.txt
        awk -v name=$2 '/Copied/ { printf("[%s] Memcpy: %d\n", name, $5) }' \
            $1/lx-fstrace-$2-13cycles.txt >> $1/lx-fstrace-$2-result-13cycles.txt
    fi
    extract_result $1/lx-fstrace-$2-30cycles.txt-timings $2 > $1/lx-fstrace-$2-result-30cycles.txt
        awk -v name=$2 '/Copied/ { printf("[%s] Memcpy: %d\n", name, $5) }' \
            $1/lx-fstrace-$2-30cycles.txt >> $1/lx-fstrace-$2-result-30cycles.txt

    cd -

    if [ "$LX_ARCH" = "xtensa" ]; then
        wait_time $1/lx-fstrace-$2-13cycles.txt $2 >> $1/lx-fstrace-$2-result-13cycles.txt
    fi
    wait_time $1/lx-fstrace-$2-30cycles.txt $2 >> $1/lx-fstrace-$2-result-30cycles.txt

    if [ "$LX_ARCH" != "xtensa" ]; then
        cp $1/lx-fstrace-$2-result-30cycles.txt $1/lx-fstrace-$2-result-13cycles.txt
    fi
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
