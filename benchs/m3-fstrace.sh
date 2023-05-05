#!/bin/bash

inputdir=`readlink -f input`

. tools/jobs.sh

cd m3
export M3_BUILD=release

if [ -z $M3_GEM5_LOG ]; then
    export M3_GEM5_LOG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG=$inputdir/test-config.py
export M3_KERNEL=rustkernel

run_bench() {
    export M3_ISA=$4
    export M3_PETYPE=$3
    export ACCEL_NUM=0
    dirname=m3-tests-$2-$3-$4-$5
    bpe=$5
    export M3_GEM5_OUT=$1/$dirname
    mkdir -p $M3_GEM5_OUT

    bootprefix=""
    if [ "$3" = "sh" ]; then
        export M3_PETYPE=b
        bootprefix="shared/"
    fi

    bench=$2

    export M3_GEM5_CPU=TimingSimpleCPU
    export M3_FS=bench-$bpe.img
    if [ "$5" = "64" ]; then
        export M3_GEM5_CPU=DerivO3CPU
    fi
    export M3_ARGS="-n 4 -t -d -u 1 $bench"
    $inputdir/${bootprefix}fstrace-minimal.cfg > $M3_GEM5_OUT/boot.gen.xml

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    # set memory and time limits
    ulimit -v 4000000   # 4GB virt mem
    ulimit -t 600       # 10min CPU time

    ./b run $M3_GEM5_OUT/boot.gen.xml -n > $M3_GEM5_OUT/output.txt 2>&1

    gzip -f $M3_GEM5_OUT/gem5.log

    if [ $? -eq 0 ] && [ "`grep 'Shutting down' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

benchs="find tar untar sqlite leveldb sha256sum sort"
bpes="64"
pes="b sh"
isas="riscv"

# bpes="32 64"
# pes="a b sh"
# isas="riscv arm x86_64"

for isa in $isas; do
    # build everything
    export M3_ISA=$isa
    ./b || exit 1

    # create FS images
    build=build/$M3_TARGET-$M3_ISA-$M3_BUILD
    for bpe in 16 32 64; do
        $build/tools/mkm3fs $build/bench-$bpe.img $build/fsdata/bench 65536 4096 $bpe
        $build/tools/mkm3fs $build/default-$bpe.img $build/fsdata/default 16384 512 $bpe
    done
done

jobs_init $2

for bpe in $bpes; do
    for isa in $isas; do
        for pe in $pes; do
            for test in $benchs; do
                jobs_submit run_bench $1 $test $pe $isa $bpe
            done
        done
    done
done

jobs_wait
