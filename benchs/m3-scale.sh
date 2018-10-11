#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-scale.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
export M3_CORES=44

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    export M3_GEM5_OUT=$1/m3-scale-$2-$3-$4
    mkdir -p $M3_GEM5_OUT

    # use a 512 MiB FS image, if many clients are writing to the same image
    if [ "$3 $4" = "16 1" ] || [ "$3 $4" = "32 2" ]; then
        export M3_FS=bench-large.img
    elif [ "$3 $4" = "32 1" ]; then
        export M3_FS=bench-huge.img
    fi

    export M3_SCALE_ARGS="$2 0 0 1 $3 $4 `stat --format="%s" build/$M3_TARGET-x86_64-$M3_BUILD/$M3_FS`"
    export M3_GEM5_FSNUM=$4

    /bin/echo -e "\e[1mStarted m3-scale-$2-$3-$4\e[0m"
    jobs_started

    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ "`grep "^/bin/fstrace-m3fs exited with 0" $M3_GEM5_OUT/output.txt | wc -l`" = "$3" ]; then
        /bin/echo -e "\e[1mFinished m3-scale-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-scale-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

# build images upfront
./b mkfs=bench-large.img -n build/$M3_TARGET-x86_64-$M3_BUILD/fsdata/bench $((128*1024)) 4096 0
./b mkfs=bench-huge.img -n build/$M3_TARGET-x86_64-$M3_BUILD/fsdata/bench $((256*1024)) 4096 0

jobs_init $2

for tr in tar untar find sqlite leveldb sha256sum sort; do
    jobs_submit run $1 $tr 1 1
    jobs_submit run $1 $tr 2 1
    jobs_submit run $1 $tr 2 2
    jobs_submit run $1 $tr 4 1
    jobs_submit run $1 $tr 4 2
    jobs_submit run $1 $tr 4 4
    jobs_submit run $1 $tr 8 1
    jobs_submit run $1 $tr 8 2
    jobs_submit run $1 $tr 8 4
    jobs_submit run $1 $tr 8 8
    jobs_submit run $1 $tr 16 1
    jobs_submit run $1 $tr 16 2
    jobs_submit run $1 $tr 16 4
    jobs_submit run $1 $tr 16 8
    jobs_submit run $1 $tr 32 1
    jobs_submit run $1 $tr 32 2
    jobs_submit run $1 $tr 32 4
    jobs_submit run $1 $tr 32 8
done

jobs_wait
