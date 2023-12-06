#!/bin/bash

source tools/helper.sh
source tools/jobs.sh

if [ -z $M3_TARGET ]; then
    echo "please define M3_TARGET." >&2
    exit 1
fi

cd m3 || exit 1

export M3_BUILD=release
export M3_ISA=riscv
export M3_FS=bench.img

if [ -z "$M3_GEM5_DBG" ]; then
    export M3_GEM5_DBG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPU=DerivO3CPU
export M3_GEM5_CPUFREQ=2GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG=config/caches.py

export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1
export M3_HW_TIMEOUT=120

./b || exit 1

run_bench() {
    dirname=m3-ycsb
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    while true; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        ./b run "boot/ycsb-bench-tcu.xml" -n </dev/null &> "$M3_OUT/output.txt"

        sed --in-place -e 's/\x1b\[0m//g' "$M3_OUT/output.txt"

        if bench_succeeded "$dirname" "$M3_OUT/output.txt" '! src/apps/bench/ycsb/lvldbserver/leveldb.cc'; then
            break
        fi
    done
}

run_bench "$1"
