#!/bin/sh

cd xtensa-linux
DISABLE_STRACE_SUPPORT=1 ./b mklx
./b mkapps
./b mkbr
./b bench > $1/lx-13cycles.txt
LX_THCMP=1 ./b bench > $1/lx-30cycles.txt
