#!/bin/sh

export LX_PLATFORM=hw
export LX_ARCH=riscv64

cd bench-lx

./b mkapps || exit 1
./b mklx || exit 1
./b mkbr || exit 1

run_bench() {
    name=$2
    outdir=$1/lx-$2
    mkdir -p $outdir

    BENCH_CMD="/bench/bin/$2" GEM5_CP=1 ./b bench

    cp run/{log,res}.txt $outdir
}

for b in syscall yield; do
    run_bench $1 $b
done
