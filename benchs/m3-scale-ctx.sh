#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/bench-scale.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img
export M3_GEM5_LOG=Dtu,DtuRegWrite,DtuCmd,DtuConnector

export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG=config/caches.py
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    export M3_GEM5_OUT=$1/m3-scale-ctx-$2-$3-$4
    mkdir -p $M3_GEM5_OUT

    export M3_CORES=$((4 + $3))

    # use a 512 MiB FS image, if many clients are writing to the same image
    if [ "$3 $4" = "16 1" ] || [ "$3 $4" = "32 2" ]; then
        ./b mkfs=bench-$2.img -n build/$M3_TARGET-x86_64-$M3_BUILD/fsdata/bench $((128*1024)) 4096 0
        export M3_FS=bench-$2.img
    fi

    /bin/echo -e "\e[1mStarted m3-scale-ctx-$2-$3-$4\e[0m"
    jobs_started

    export M3_SCALE_ARGS="$2 1 0 1 $3 $4 `stat --format="%s" build/$M3_TARGET-x86_64-$M3_BUILD/$M3_FS`"
    export M3_GEM5_FSNUM=$4

    ./b run $cfg -n &>$M3_GEM5_OUT/output.txt

    if [ "`grep "^/bin/fstrace-m3fs exited with 0" $M3_GEM5_OUT/output.txt | wc -l`" = "$3" ]; then
        /bin/echo -e "\e[1mFinished m3-scale-ctx-$2-$3-$4:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-scale-ctx-$2-$3-$4:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

jobs_submit run $1 tar 1 1
jobs_submit run $1 untar 1 1
jobs_submit run $1 sha256sum 1 1
jobs_submit run $1 leveldb 1 1
jobs_submit run $1 sort 1 1
jobs_submit run $1 find 1 1
jobs_submit run $1 sqlite 1 1

jobs_submit run $1 tar 2 1
jobs_submit run $1 untar 2 1
jobs_submit run $1 sha256sum 2 1
jobs_submit run $1 leveldb 2 1
jobs_submit run $1 sort 2 1
jobs_submit run $1 find 2 1
jobs_submit run $1 sqlite 2 1

jobs_submit run $1 tar 4 1
jobs_submit run $1 untar 4 1
jobs_submit run $1 sha256sum 4 1
jobs_submit run $1 leveldb 4 1
jobs_submit run $1 sort 4 1
jobs_submit run $1 find 4 1
jobs_submit run $1 sqlite 4 1

jobs_submit run $1 tar 8 1
jobs_submit run $1 untar 8 1
jobs_submit run $1 sha256sum 8 1
jobs_submit run $1 leveldb 8 2
jobs_submit run $1 sort 8 1
jobs_submit run $1 find 8 2
jobs_submit run $1 sqlite 8 2

jobs_submit run $1 tar 16 4
jobs_submit run $1 untar 16 4
jobs_submit run $1 sha256sum 16 1
jobs_submit run $1 leveldb 16 4
jobs_submit run $1 sort 16 1
jobs_submit run $1 find 16 4
jobs_submit run $1 sqlite 16 4

jobs_submit run $1 sha256sum 32 1
jobs_submit run $1 sort 32 1

jobs_wait
