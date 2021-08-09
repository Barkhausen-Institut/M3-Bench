#!/bin/bash

#set -x

rootdir=$(readlink -f .)
inputdir=$(readlink -f input)

cd m3

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1
export M3_HW_TIMEOUT=180

./b || exit 1

build=build/$M3_TARGET-$M3_ISA-$M3_BUILD
$build/tools/mkm3fs $build/bench-64.img $build/src/fs/bench 65536 4096 64
export M3_FS=bench-64.img

reset_bitfile() {
    cmd="cd tcu/fpga_tools/testcases/tc_rocket_boot"
    cmd="$cmd && source ~/Applications/Xilinx/Vivado_Lab/2019.1/settings64.sh"
    cmd="$cmd && BITFILE=/home/hrniels/tcu/fpga_tools/bitfiles/fpga_top_v4.4.4.bit make program-fpga"
    ssh -t $M3_HW_SSH $cmd
    sleep 5
}

run_bench() {
    dirname=m3-$2-$3-$4
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    bootprefix=""
    if [ "$4" = "sh" ]; then
        bootprefix="shared/"
    fi

    while true; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        export M3_WORKLOAD=/data/$3-workload.wl
        $inputdir/${bootprefix}ycsb-bench.cfg > $M3_OUT/boot.gen.xml

        ./b run $M3_OUT/boot.gen.xml -n 2>&1 | tee $M3_OUT/output.txt

        sed --in-place -e 's/\x1b\[0m//g' $M3_OUT/output.txt

        if [ $? -eq 0 ] &&
            [ "$(grep 'Server Side:' $M3_OUT/output.txt)" != "" ] &&
            [ "$(grep 'Shutting down' $M3_OUT/output.txt)" != "" ] &&
            [ "$(grep ' exited with ' $M3_OUT/output.txt)" = "" ]; then
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
            break
        else
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
            if [ "$(grep 'assert len' $M3_OUT/output.txt)" == "" ] &&
                [ "$(grep 'Kernel is ready' $M3_OUT/output.txt)" = "" ]; then
                reset_bitfile
            fi
        fi
    done
}

for t in iso sh; do
    for wl in read insert update scan mixed; do
        run_bench $1 ycsb $wl $t
    done
done
