#!/bin/bash

fstrace=`readlink -f input/fstrace.cfg`

. tools/jobs.sh

cd m3
export M3_BUILD=release

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12

run_bench() {
    export M3_FSBPE=$5
    export M3_ISA=$4
    dirname=m3-tests-$2-$3-$4-$5
    export M3_GEM5_OUT=$1/$dirname
    mkdir -p $M3_GEM5_OUT

    bench=$2

    export M3_GEM5_CPU=TimingSimpleCPU
    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ]; then
        export M3_FS=default.img
        bench=boot/$bench.cfg
    else
        export M3_FS=bench.img
        if [ "$5" = "64" ]; then
            export M3_GEM5_CPU=DerivO3CPU
        fi
        export FSTRACE_ARGS="-n 4 $bench"
        if [[ "$bench" =~ "bench" ]]; then
            bench=boot/$bench.cfg
        else
            bench=$fstrace
        fi
    fi

    if [ "$3" = "a" ]; then
        export M3_GEM5_CFG=config/spm.py
    elif [ "$3" = "b" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=0 M3_GEM5_DTUPOS=0
    elif [ "$3" = "c" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"

    ./b 2>&1 > $M3_GEM5_OUT/output.txt || exit

    /bin/echo -e "\e[1mStarted $dirname\e[0m"
    jobs_started

    ./b run $bench -n >> $M3_GEM5_OUT/output.txt

    gzip -f $M3_GEM5_OUT/gem5.log

    if [ $? -eq 0 ] && [ "`grep 'Shutting down' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for test in rust-unittests rust-benchs unittests cpp-benchs find tar untar sqlite leveldb sha256sum sort; do
    for isa in arm x86_64; do
        for bpe in 2 4 8 16 32 64; do
            for pe in a b c; do
                if [ "$isa" = "arm" ] && [ "$pe" = "c" ]; then
                    continue;
                fi

                jobs_submit run_bench $1 $test $pe $isa $bpe
            done
        done
    done
done

jobs_wait
