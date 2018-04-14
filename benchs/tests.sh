#!/bin/bash

. tools/jobs.sh

cd m3
export M3_BUILD=release

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CPU=TimingSimpleCPU
export M3_CORES=12

run_bench() {
    export M3_FSBPE=$6
    export M3_ISA=$5
    export M3_KERNEL=$3
    export M3_GEM5_OUT=$1/m3-tests-$2-$3-$4-$5-$6
    mkdir -p $M3_GEM5_OUT

    if [ "$2" = "unittests" ] || [ "$2" = "rust-unittests" ]; then
        export M3_FS=default.img
    else
        export M3_FS=bench.img
    fi

    if [ "$4" = "a" ]; then
        export M3_GEM5_CFG=config/spm.py
    elif [ "$4" = "b" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=0 M3_GEM5_DTUPOS=0
    elif [ "$4" = "c" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
    fi

    /bin/echo -e "\e[1mStarting m3-tests-$2-$3-$4-$5-$6\e[0m"

    ./b 2>&1 > $M3_GEM5_OUT/output.txt || exit

    /bin/echo -e "\e[1mStarted m3-tests-$2-$3-$4-$5-$6\e[0m"
    jobs_started

    ./b run boot/$2.cfg -n >> $M3_GEM5_OUT/output.txt

    if [ $? -eq 0 ] && [ "`grep 'All tests successful!' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-tests-$2-$3-$4-$5-$6:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-tests-$2-$3-$4-$5-$6:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for kernel in kernel; do
    for test in rust-unittests unittests; do
        for isa in arm; do
            for bpe in 2 4 8 16 32 64; do
                for pe in a b c; do
                    if [ "$isa" = "arm" ] && [ "$pe" = "c" ]; then
                        continue;
                    fi

                    jobs_submit run_bench $1 $test $kernel $pe $isa $bpe
                done
            done
        done
    done
done

jobs_wait
