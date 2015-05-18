#!/bin/sh

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench

./b run boot/bench-syscall.cfg
./tools/bench.sh xtsc.log > $1/m3-syscall.txt

./b run boot/bench-vpes.cfg
./tools/bench.sh xtsc.log > $1/m3-vpes.txt
