#!/bin/sh

cd m3
export M3_BUILD=bench

./b run boot/bench-syscall.cfg
./src/tools/bench.sh $M3_LOG 1 > $1/m3-syscall.txt

./b run boot/bench-vpes.cfg
./src/tools/bench.sh $M3_LOG 1 > $1/m3-vpes.txt
