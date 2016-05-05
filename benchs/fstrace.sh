#!/bin/bash

source tools/fstrace-helper.sh

wait_time() {
    echo -n "[$2] Wait: "
    ./tools/timedstrace.php waittime $1-strace $1-timings
}

run_bench() {
    cd xtensa-linux

    ./b mkbr
    ./b fsbench > $1/lx-fstrace-$2-13cycles.txt
    # better regenerate the filesystem image, in case it is broken
    ./b mkbr
    LX_THCMP=1 ./b fsbench > $1/lx-fstrace-$2-30cycles.txt

    cd -

    gen_timedtrace $1/lx-fstrace-$2-13cycles.txt $LX_ARCH
    gen_timedtrace $1/lx-fstrace-$2-30cycles.txt $LX_ARCH

    cd m3/XTSC
    export M3_TARGET=t3 M3_BUILD=bench M3_FS=bench.img

    ./b

    ./build/t3-sim-bench/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2-30cycles.txt-timedstrace > $1/lx-fstrace-$2-30cycles.txt-opcodes.c
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c apps/fstrace/m3fs/trace.c

    ./b run boot/fstrace.cfg
    ./tools/bench.sh xtsc.log > $1/m3-fstrace.$2-txt

    extract_result $1/lx-fstrace-$2-13cycles.txt-timings $2 > $1/lx-fstrace-$2-result-13cycles.txt
    extract_result $1/lx-fstrace-$2-30cycles.txt-timings $2 > $1/lx-fstrace-$2-result-30cycles.txt

    cd -

    wait_time $1/lx-fstrace-$2-13cycles.txt $2 >> $1/lx-fstrace-$2-result-13cycles.txt
    wait_time $1/lx-fstrace-$2-30cycles.txt $2 >> $1/lx-fstrace-$2-result-30cycles.txt
}

cd xtensa-linux

./b mklx
./b mkapps

cd -

FSBENCH_CMD="find /default -name test" run_bench $1 find

FSBENCH_CMD="tar -cf /tmp/test.tar /tardata" run_bench $1 tar

FSBENCH_CMD="tar -xf /test.tar -C /tmp" run_bench $1 untar

FSBENCH_CMD="/bench/sqlite /tmp/test.db" run_bench $1 sqlite
