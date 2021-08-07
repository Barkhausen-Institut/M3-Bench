#!/bin/bash

rootdir=$(readlink -f .)
inputdir=$(readlink -f input)

cd m3

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1
export M3_FS=bench.img

./b || exit 1

run_bench() {
    dirname=m3-$2
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    /bin/echo -e "\e[1mStarting $dirname\e[0m"

    ./b run boot/hw/$2.xml -n > $M3_OUT/output.txt 2>&1

    if [ $? -eq 0 ] && $rootdir/tools/check_result.py $M3_OUT/output.txt 2>/dev/null; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

run_bench $1 voiceassist
run_bench $1 voiceassist-shared
