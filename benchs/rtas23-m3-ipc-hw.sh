#!/bin/bash

source tools/helper.sh

cd m3 || exit 1

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1

./b || exit 1

run_bench() {
    type=$2
    dirname=m3-ipc-hw-$type
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    while true; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        ./b run "boot/bench-pingpong-$type.xml" -n &> "$M3_OUT/output.txt"

        sed --in-place -e 's/\x1b\[0m//g' "$M3_OUT/output.txt"

        if bench_succeeded "$dirname" "$M3_OUT/output.txt" 'pingpong'; then
            break
        fi
    done
}

for t in remote local multi; do
    run_bench "$1" "$t"
done
