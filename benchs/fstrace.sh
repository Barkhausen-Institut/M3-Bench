#!/bin/bash

run_bench() {
    cd xtensa-linux

    LX_THCMP=1 ./b fsbench > $1/lx-fstrace-$2-30cycles.txt

    cd -

    gen_timedtrace() {
        grep -B10000 "===" $1 | grep -v "===" > $1-strace
        grep -A10000 "===" $1 | grep -v "===" > $1-timings
        ./tools/timedstrace.php trace $1-strace $1-timings > $1-timedstrace
    }

    gen_timedtrace $1/lx-fstrace-$2-30cycles.txt

    awk '{ print $1, $2, $4 - $3 }' $1/lx-fstrace-$2-30cycles.txt-timings \
       > $1/lx-fstrace-$2-30cycles.txt-timings-human

    cd m3/XTSC
    export M3_TARGET=t3 M3_BUILD=bench M3_FS=bench.img

    ./b

    # first, make the strace a little more friendly for strace2cpp
    sed --in-place -e 's/\/\* \([[:digit:]]*\) entries \*\//\1/' $1/lx-fstrace-$2-30cycles.txt-timedstrace
    sed --in-place -e 's/\/\* d_reclen == 0, problem here \*\///' $1/lx-fstrace-$2-30cycles.txt-timedstrace

    ./build/t3-sim-bench/apps/fstrace/strace2cpp/strace2cpp \
        < $1/lx-fstrace-$2-30cycles.txt-timedstrace > $1/lx-fstrace-$2-30cycles.txt-opcodes.c
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c apps/fstrace/m3fs/trace.c

    ./b run boot/fstrace.cfg
    ./tools/bench.sh xtsc.log > $1/m3-fstrace.$2-txt

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
    ' $1/lx-fstrace-$2-30cycles.txt-timings > $1/lx-fstrace-$2-result.txt

    cd -
    echo -n "Wait: " >> $1/lx-fstrace-$2-result.txt
    ./tools/timedstrace.php waittime $1/lx-fstrace-$2-30cycles.txt-strace \
        $1/lx-fstrace-$2-30cycles.txt-timings >> $1/lx-fstrace-$2-result.txt
}

cd xtensa-linux

./b mklx
./b mkapps
./b mkbr

cd -

FSBENCH_CMD="find /default -name test" run_bench $1 find

FSBENCH_CMD="tar -cf /tmp/test.tar /tardata" run_bench $1 tar
