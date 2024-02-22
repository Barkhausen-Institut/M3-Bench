#!/bin/bash

cfg=$(readlink -f input/gem5-rtas23.py)

. tools/jobs.sh

cd m3 || exit 1

export M3_BUILD=release
export M3_TARGET=gem5
export M3_ISA=x86_64
if [ -z "$M3_GEM5_LOG" ]; then
    export M3_GEM5_LOG=Thread,Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPU=DerivO3CPU
export M3_GEM5_CPUFREQ=2GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG="$cfg"

./b || exit 1

run_bench() {
    dirname=m3-tcusleep
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    if ./b run "boot/bench-tcusleep.xml" -n < /dev/null &> "$M3_OUT/output.txt"; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init "$2"

jobs_submit run_bench "$1"

jobs_wait
