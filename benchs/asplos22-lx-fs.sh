#!/bin/sh

export LX_PLATFORM=hw
export LX_ARCH=riscv64

cd bench-lx

./b mkapps || exit 1
./b mklx || exit 1
./b mkbr || exit 1

run_bench() {
    outdir=$1/lx-$2
    mkdir -p $outdir

    ./b bench

    cp run/{log,res}.txt $outdir
}

BENCH_CMD="/bench/bin/read /bench/pipedata/2048k.txt" run_bench $1 read
BENCH_CMD="/bench/bin/write /tmp/foo 2097152" run_bench $1 write
