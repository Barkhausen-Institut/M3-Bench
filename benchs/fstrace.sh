#!/bin/bash

source tools/fstrace-helper.sh

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
        GEM5_CP=1 ./b fsbench > $1/lx-fstrace-$2-30cycles.txt
    fi

    cd -

    if [ "$LX_ARCH" = "xtensa" ]; then
        gen_timedtrace $1/lx-fstrace-$2-13cycles.txt $LX_ARCH
    fi
    gen_timedtrace $1/lx-fstrace-$2-30cycles.txt $LX_ARCH

    cd m3
    export M3_BUILD=bench M3_FS=bench.img

    ./b

    ./build/$M3_TARGET-$M3_BUILD/src/apps/fstrace/strace2cpp/strace2cpp \
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

FSBENCH_CMD="find /finddata/dir -name test" run_bench $1 find-multi

FSBENCH_CMD="find /finddata/dir-160 -name test" run_bench $1 find

FSBENCH_CMD="find /finddata/dir-320-multi -name test" run_bench $1 find

FSBENCH_CMD="tar -cf /tmp/test.tar /tardata/tar-3968" run_bench $1 tar

FSBENCH_CMD="tar -xf /untardata/tar-3968.tar -C /tmp" run_bench $1 untar

FSBENCH_CMD="/bench/sqlite /tmp/test.db" run_bench $1 sqlite

# FSBENCH_CMD="wc /large.txt" run_bench $1 wc

# FSBENCH_CMD="grep -rn test /finddata/dir-40 /largetext.txt" run_bench $1 grep

# FSBENCH_CMD="sha256sum /largetext.txt" run_bench $1 sha256sum

# FSBENCH_CMD="sort -o /tmp/sorted.txt /largetext.txt" run_bench $1 sort

# FSBENCH_CMD="tail /largetext.txt" run_bench $1 tail
