#!/bin/bash

export LX_PLATFORM=gem5
export LX_ARCH=x86_64
export LX_CORES=2

gem5dir=$(readlink -f gem5-official)
export GEM5_DIR="$gem5dir"
export GEM5_CP=1 GEM5_FLAGS=""
export GEM5_CPU=DerivO3CPU GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz

cd bench-lx || exit 1

./b mkapps || exit 1
# ./b mklx || exit 1

run_bench() {
    outdir=$1/lx-$2
    mkdir -p "$outdir"
    export GEM5_OUT="$outdir"

    /bin/echo -e "\e[1mStarting $2\e[0m"

    ./b bench

    /bin/echo -e "\e[1mFinished $2:\e[0m \e[1;32mSUCCESS\e[0m"
}

BENCH_CMD="/bench/bin/pingpong" run_bench "$1" pingpong
