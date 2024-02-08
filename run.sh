#!/bin/bash

set -e

source fpga.sh

GEM5_DIR=$(readlink -f bench-lx/gem5)
export LX_CORES=2 LX_PLATFORM=gem5 GEM5_DIR

mkdir -p results
res=$(readlink -f results)

bench() {
    /bin/echo -e "\e[1mStarting $1 benchmark...\e[0m"
    "./benchs/$1.sh" "$res" "$(nproc)" || exit 1
}

M3_TARGET=gem5 bench rtas23-m3-disturb
M3_TARGET=hw bench rtas23-m3-disturb
M3_TARGET=gem5 bench rtas23-m3-tcusleep
bench rtas24-m3-sendprios
M3_ISA=riscv bench rtas23-m3-ipc-gem5
M3_ISA=x86_64 bench rtas23-m3-ipc-gem5
bench rtas23-m3-ipc-hw
LX_ARCH=x86_64 bench rtas23-lx-mwait
LX_ARCH=riscv64 bench rtas23-lx-pingpong
LX_ARCH=x86_64 bench rtas23-lx-pingpong
bench rtas24-nre-pingpong

plots="rtas23-disturb rtas24-sendprios rtas23-mwait rtas23-pingpong"

for p in $plots; do
    /bin/echo -e "\e[1mStarting $p post processing...\e[0m"
    "./plots/$p/post.sh" "$res" || exit 1
done

for p in $plots; do
    /bin/echo -e "\e[1mStarting $p plot...\e[0m"
    "./plots/$p/plot.sh" "$res" || exit 1
done
