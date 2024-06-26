#!/bin/bash

cfg=$(readlink -f input/gem5-rtas23.py)

if [ -z "$M3_ISA" ]; then
    echo "Please define M3_ISA." >&2
    exit 1
fi

. tools/jobs.sh

cd m3 || exit 1

export M3_BUILD=release
export M3_TARGET=gem5
if [ -z "$M3_GEM5_LOG" ]; then
    export M3_GEM5_LOG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPU=DerivO3CPU
export M3_GEM5_CPUFREQ=2GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG="$cfg"

./b || exit 1

run_bench() {
    type=$2
    dirname=m3-ipc-gem5-$M3_ISA-$type
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    if ./b run "boot/bench-pingpong-$type.xml" -n < /dev/null &> "$M3_OUT/output.txt"; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init "$2"

for t in remote local multi; do
    jobs_submit run_bench "$1" "$t"
done

jobs_wait
