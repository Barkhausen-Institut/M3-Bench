#!/bin/sh

cd xtensa-linux

./b mkapps
./b mklx
./b mkbenchfs

export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
export GEM5_OUT=$1/lx-pagefaults
mkdir -p $GEM5_OUT

BENCH_CMD="/bench/bin/pagefault" GEM5_CP=1 ./b bench >/dev/null 2>/dev/null
