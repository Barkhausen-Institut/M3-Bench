#!/bin/bash

. tools/jobs.sh

if [ -z $LX_ARCH ]; then
    echo "Please define LX_ARCH." >&2
    exit 1
fi

export LX_PLATFORM=gem5
export LX_BUILD=release
export LX_CORES=2

gem5dir=$(readlink -f gem5-official)
export GEM5_DIR="$gem5dir"
export GEM5_CP=1 GEM5_FLAGS=""
export GEM5_CPU=DerivO3CPU GEM5_CPUFREQ=2GHz GEM5_MEMFREQ=1GHz

cd bench-lx || exit 1

# ./b mkapps || exit 1
# ./b mklx || exit 1

run_bench() {
    msgsize="$2"
    dirname="lx-pingpong-$LX_ARCH-$msgsize"
    outdir=$1/$dirname
    mkdir -p "$outdir"
    export GEM5_OUT="$outdir"

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    BENCH_CMD="$msgsize" ./b pingpong >/dev/null 2>&1

    /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
}

jobs_init "$2"

for sz in 1 32 256 2032; do
    jobs_submit run_bench "$1" "$sz"
done

jobs_wait
