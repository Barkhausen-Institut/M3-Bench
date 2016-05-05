#!/bin/bash

if [ "$LX_ARCH" = "" ]; then
    echo "Please set LX_ARCH first!" 1>&2
    exit
fi

source tools/fstrace-helper.sh

run_bench() {
    cd xtensa-linux

    if [ "$LX_ARCH" = "xtensa" ]; then
        ./b mkbr
        ./b mkdisk
        LX_THCMP=1 ./b fsbench > $1/lx-fstrace-$2-$LX_ARCH.txt
    else
        GEM5_CP=1 ./b fsbenchgem5 > $1/lx-fstrace-$2-$LX_ARCH.txt
    fi

    cd -

    gen_timedtrace $1/lx-fstrace-$2-$LX_ARCH.txt $LX_ARCH

    cd m3/XTSC
    export M3_TARGET=t3 M3_BUILD=bench M3_FS=bench.img

    ./b

    ./build/t3-sim-bench/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2-$LX_ARCH.txt-timedstrace > $1/lx-fstrace-$2-$LX_ARCH.txt-opcodes.c

    cd -
}

if [ "$LX_ARCH" = "xtensa" ]; then
    cd xtensa-linux

    ./b mklx
    ./b mkapps

    cd -
fi

for count in 40 80 160 320 640; do
    FSBENCH_CMD="find /finddata/dir-$count -name test" run_bench $1 find-$count
done

for size in 384 896 3968 8064; do
    FSBENCH_CMD="tar -cf /tmp/test.tar /tardata/tar-$size" run_bench $1 tar-$size
done

for count in 40 80 160; do
    FSBENCH_CMD="tar -cf /tmp/test.tar /finddata/dir-$count" run_bench $1 tar-many-$count
done

for size in 384 896 3968 8064; do
    FSBENCH_CMD="tar -xf /untardata/tar-$size.tar -C /tmp" run_bench $1 untar-$size
done

for count in 40 80 160; do
    FSBENCH_CMD="tar -xf /untardata/tar-$count.tar -C /tmp" run_bench $1 untar-many-$count
done

FSBENCH_CMD="/bench/sqlite /tmp/test.db" run_bench $1 sqlite
