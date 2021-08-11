#!/bin/sh

export LX_PLATFORM=hw
export LX_ARCH=riscv64

cd bench-lx

./b mkapps || exit 1
# ./b mklx || exit 1
./b mkbr || exit 1

run_bench() {
    outdir=$1/lx-$2
    mkdir -p $outdir

    ./b bench

    cp run/{log,res}.txt $outdir
}

BENCH_CMD="/bench/bin/netlat 192.168.42.232 1338" run_bench $1 netlat
