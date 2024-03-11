#!/bin/bash

set -e

cfg=$(readlink -f input/multichip.py)
boot=$(readlink -f input/dist-accel.xml)

. tools/jobs.sh

cd m3

export M3_BUILD=bench
export M3_TARGET=gem5 M3_ISA=riscv
if [ -z "$M3_GEM5_LOG" ]; then
    export M3_GEM5_LOG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPU=DerivO3CPU
export M3_GEM5_CPUFREQ=4GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_CFG="$cfg"

./b

run_bench() {
    ty=$2
    sz=$3
    dirname=m3-distaccel-$ty-$sz
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    export M3_GEM5_CORES=8
    export M3_GEM5_BRDELAY="500ns"
    export M3_MODE=$ty
    export M3_BUF_SIZE=$sz

    "$boot" > "$M3_OUT/boot.gen.xml"

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    if ./b run "$M3_OUT/boot.gen.xml" -n < /dev/null &> "$M3_OUT/output.txt" &&
        [ "$(grep PERF "$M3_OUT/output.txt")" != "" ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init "$2"

for sz in 1 2 4 8 16 32; do
    jobs_submit run_bench "$1" "srv-central" "$((sz * 1024))"
    jobs_submit run_bench "$1" "srv-dist" "$((sz * 1024))"
    jobs_submit run_bench "$1" "cli" "$((sz * 1024))"
done

jobs_wait
