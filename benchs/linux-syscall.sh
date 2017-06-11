#!/bin/sh

cd xtensa-linux

./b mkapps
./b mklx
./b mkbr

export GEM5_OUT=$1/lx-syscall
mkdir -p $GEM5_OUT

BENCH_CMD="/bench/bin/syscall" GEM5_CP=1 ./b bench >/dev/null 2>/dev/null
