#!/bin/sh

. tools/jobs.sh

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5`

cd xtensa-linux

./b mkapps
./b mklx
./b mkbenchfs

export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
export GEM5_FLAGS=Dtu

run_bench() {
    jobs_started

    export GEM5_OUT=$1/lx-$3-$2
    mkdir -p $GEM5_OUT

    /bin/echo -e "\e[1mStarted lx-$3-$2\e[0m"

    if [ "$3" = "clone" ]; then
        BENCH_CMD="/bench/bin/fork-$2" GEM5_CP=1 ./b bench >/dev/null 2>/dev/null
    else
        BENCH_CMD="/bench/bin/exec /bench/bin/fork-$2" GEM5_CP=1 ./b bench >/dev/null 2>/dev/null
    fi

    /bin/echo -e "\e[1mFinished lx-$3-$2:\e[0m \e[1;32mSUCCESS\e[0m"
}

jobs_init $2

for b in clone exec; do
    for size in $((1)) $((1024 * 2048)) $((1024 * 4096)) $((1024 * 8192)); do
        jobs_submit run_bench $1 $size $b
    done
done

jobs_wait
