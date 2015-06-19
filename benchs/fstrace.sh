#!/bin/bash

gen_timedtrace() {
    grep -B10000 "===" $1 | grep -v "===" > $1-strace
    grep -A10000 "===" $1 | grep -v "===" > $1-timings

    # for untar: prefix relative paths with /tardata/
    sed --in-place -e 's/("\([^/]\)/("\/tardata\/\1/g' $1-strace

    ./tools/timedstrace.php trace $1-strace $1-timings > $1-timedstrace

    # make the strace a little more friendly for strace2cpp
    sed --in-place -e 's/\/\* \([[:digit:]]*\) entries \*\//\1/' $1-timedstrace
    sed --in-place -e 's/\/\* d_reclen == 0, problem here \*\///' $1-timedstrace

    awk '{ print $1, $2, $4 - $3 }' $1-timings > $1-timings-human
}

extract_result() {
    awk 'BEGIN {
        start = 0
    }

    END {
        print "Total:", end - start
    }

    /Copied/ {
        print "Memcpy:", $5
    }

    /^[[:space:]]*\[[[:space:]]*[[:digit:]]+\][[:space:]]*66/ {
        if(start == 0) {
            start = $3
        }
    }

    /^[[:space:]]*\[[[:space:]]*[[:digit:]]+\][[:space:]]*/ {
        end = $3
    }
    ' $1
}

wait_time() {
    echo -n "Wait: " >> $2
    ./tools/timedstrace.php waittime $1-strace $1-timings >> $2
}

run_bench() {
    cd xtensa-linux

    ./b fsbench > $1/lx-fstrace-$2-13cycles.txt
    # better regenerate the filesystem image, in case it is broken
    ./b mkbr
    LX_THCMP=1 ./b fsbench > $1/lx-fstrace-$2-30cycles.txt

    cd -

    gen_timedtrace $1/lx-fstrace-$2-13cycles.txt
    gen_timedtrace $1/lx-fstrace-$2-30cycles.txt

    cd m3/XTSC
    export M3_TARGET=t3 M3_BUILD=bench M3_FS=bench.img

    ./b

    ./build/t3-sim-bench/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2-30cycles.txt-timedstrace > $1/lx-fstrace-$2-30cycles.txt-opcodes.c
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c apps/fstrace/m3fs/trace.c

    ./b run boot/fstrace.cfg
    ./tools/bench.sh xtsc.log > $1/m3-fstrace.$2-txt

    extract_result $1/lx-fstrace-$2-13cycles.txt-timings > $1/lx-fstrace-$2-13cycles-result.txt
    extract_result $1/lx-fstrace-$2-30cycles.txt-timings > $1/lx-fstrace-$2-30cycles-result.txt

    cd -

    wait_time $1/lx-fstrace-$2-13cycles.txt $1/lx-fstrace-$2-13cycles-result.txt
    wait_time $1/lx-fstrace-$2-30cycles.txt $1/lx-fstrace-$2-30cycles-result.txt
}

cd xtensa-linux

./b mklx
./b mkapps
./b mkbr

cd -

FSBENCH_CMD="find /default -name test" run_bench $1 find

FSBENCH_CMD="tar -cf /tmp/test.tar /tardata" run_bench $1 tar

FSBENCH_CMD="tar -xf /test.tar -C /tardata" run_bench $1 untar
