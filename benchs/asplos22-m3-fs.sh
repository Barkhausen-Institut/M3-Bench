#!/bin/bash

rootdir=$(readlink -f .)
inputdir=$(readlink -f input)

cd m3

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1

./b || exit 1

build=build/$M3_TARGET-$M3_ISA-$M3_BUILD
$build/tools/mkm3fs $build/bench-64.img $build/src/fs/bench 65536 4096 64
export M3_FS=bench-64.img

run_bench() {
    dirname=m3-$2
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    /bin/echo -e "\e[1mStarting $dirname\e[0m"

    ./b run boot/hw/bench-$2.xml -n > $M3_OUT/output.txt 2>&1

    if [ $? -eq 0 ] && $rootdir/tools/check_result.py $M3_OUT/output.txt 2>/dev/null; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

run_bench $1 fs
run_bench $1 fs-shared
