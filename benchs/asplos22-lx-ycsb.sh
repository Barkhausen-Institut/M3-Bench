#!/bin/sh

export LX_PLATFORM=hw
export LX_ARCH=riscv64

cd bench-lx

./b mkapps || exit 1
./b mkbr || exit 1
./b mklx || exit 1

run_bench() {
    outdir=$1/lx-$2
    mkdir -p $outdir

    ./b bench

    cp run/{log,res}.txt $outdir
}

for wl in read insert update scan mixed; do
    BENCH_CMD="/bench/bin/exec 10 /bench/bin/ycsbserver 192.168.42.15 1337 /bench/$wl-workload.wl /tmp/foo" run_bench $1 ycsb-$wl
done
