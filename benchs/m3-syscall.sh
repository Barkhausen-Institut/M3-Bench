#!/bin/bash

cd m3
export M3_BUILD=bench

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=3
# export M3_GEM5_CPU=timing

run_bench() {
    export M3_GEM5_OUT=$1/m3-syscall-$2-$3 M3_GEM5_MMU=$2 M3_GEM5_DTUPOS=$3
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-syscall-$2-$3\e[0m"

    ./b run boot/bench-syscall.cfg -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-syscall-$2-$3\e[0m"
}

./b

for mmu in 0 1; do
    for dtupos in 0 1 2; do
        if [ $mmu -eq 1 ] || [ $dtupos == 0 ]; then
            run_bench $1 $mmu $dtupos
        fi
    done
done
