#!/bin/bash

. tools/jobs.sh

rdcfg=`readlink -f input/filereader.cfg`
wrcfg=`readlink -f input/filewriter.cfg`
cpcfg=`readlink -f input/filecopy.cfg`

cd m3
export M3_BUILD=bench

export M3_FS=bench.img
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=3

# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    export M3_FS_CLEAR=$3
    export M3_GEM5_OUT=$1/m3-fs-$2-$5
    export M3_GEM5_CFG=config/$5.py
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-fs-$2-$5\e[0m"

    ./b run $4 -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-fs-$2-$5\e[0m"
}

./b

jobs_init $2

for c in spm caches; do
    jobs_submit run_bench $1 read 0 $rdcfg $c
    jobs_submit run_bench $1 write 0 $wrcfg $c
    jobs_submit run_bench $1 write-clear 1 $wrcfg $c
    jobs_submit run_bench $1 copy 0 $cpcfg $c
done

jobs_wait
