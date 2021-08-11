#!/bin/bash

source tools/helper.sh

rootdir=$(readlink -f .)

cd m3

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
# export M3_HW_SSH=syn M3_HW_FPGA=0
export M3_HW_VM=1 M3_HW_RESET=1
export M3_HW_TIMEOUT=10

./b || exit 1

run_bench() {
    dirname=m3-netlat-$2
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    while true; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        if [ "$2" = "shared" ]; then
            ./b run boot/hw/netlat-shared.xml -n 2>&1 | tee $M3_OUT/output.txt
        else
            ./b run boot/hw/netlat.xml -n 2>&1 | tee $M3_OUT/output.txt
        fi

        sed --in-place -e 's/\x1b\[0m//g' $M3_OUT/output.txt

        if bench_succeeded $dirname $M3_OUT/output.txt 'All tests successful!'; then
            break
        fi
    done
}

run_bench $1 shared
run_bench $1 iso
