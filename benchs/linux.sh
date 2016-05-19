#!/bin/sh

cd xtensa-linux

if [ "$LX_ARCH" = "xtensa" ]; then
    DISABLE_STRACE_SUPPORT=1 ./b mklx
    ./b mkapps
    ./b mkbr
    ./b bench > $1/lx-13cycles.txt
    LX_THCMP=1 ./b bench > $1/lx-30cycles.txt
else
    GEM5_CP=1 ./b bench > $1/lx-30cycles.txt
    # pretend we have two different times, as on xtensa, to keep the current infrastructure
    cp $1/lx-30cycles.txt $1/lx-13cycles.txt
fi
