#!/bin/bash

source tools/helper.sh

rootdir=$(readlink -f .)
inputdir=$(readlink -f input)

cd m3

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1
export M3_FS=bench.img
export M3_HW_TIMEOUT=60

./b || exit 1

run_bench() {
    dirname=m3-$2
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    while true; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        ./b run boot/hw/$2.xml -n 2>&1 | tee $M3_OUT/output.txt

        if bench_succeeded $dirname $M3_OUT/output.txt 'Total Time:'; then
            break
        fi
    done
}

run_bench $1 voiceassist
run_bench $1 voiceassist-shared
