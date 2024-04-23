#!/bin/bash

set -e

source fpga.sh

GEM5_DIR=$(readlink -f bench-lx/gem5)
export LX_CORES=2 LX_PLATFORM=gem5 GEM5_DIR

/bin/echo -e "\e[1m==> Building Linux ...\e[0m"
(
    cd bench-lx
    LX_ARCH=riscv64 ./b mkbr
    LX_ARCH=riscv64 ./b mklx
    LX_ARCH=x86_64 ./b mkbr
    LX_ARCH=x86_64 ./b mklx
)
/bin/echo -e "\e[1m==> Linux is built.\e[0m"

/bin/echo -e "\e[1m==> Building gem5 for Linux ...\e[0m"
(
    cd bench-lx/gem5
    scons "-j$(nproc)" build/{RISCV,X86}/gem5.opt
)
/bin/echo -e "\e[1m==> gem5 for Linux is built.\e[0m"

/bin/echo -e "\e[1m==> Creating Linux checkpoints ...\e[0m"
(
    cd bench-lx
    LX_ARCH=riscv64 ./b warmup &
    LX_ARCH=x86_64 ./b warmup &
    wait
)
/bin/echo -e "\e[1m==> Checkpoints done.\e[0m"

/bin/echo -e "\e[1m==> Building M³ cross compiler ...\e[0m"
(
    cd m3/cross
    ./build.sh riscv
    ./build.sh x86_64
)
/bin/echo -e "\e[1m==> M³ cross compiler is built.\e[0m"

/bin/echo -e "\e[1m==> Building M³ ...\e[0m"
(
    cd m3
    rustup show
    M3_TARGET=gem5 M3_ISA=riscv ./b
    M3_TARGET=gem5 M3_ISA=x86_64 ./b
    M3_TARGET=hw ./b
)
/bin/echo -e "\e[1m==> M³ is built.\e[0m"

/bin/echo -e "\e[1m==> Building gem5 ...\e[0m"
(
    cd m3/platform/gem5
    scons "-j$(nproc)" build/{RISCV,X86}/gem5.opt
)
/bin/echo -e "\e[1m==> gem5 is built.\e[0m"
