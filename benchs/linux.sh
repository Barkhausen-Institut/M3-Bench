#!/bin/sh

if [ "$LX_ARCH" = "" ]; then
    echo "Please set LX_ARCH first!" 1>&2
    exit
fi

cd xtensa-linux

if [ "$LX_ARCH" = "xtensa" ]; then
    DISABLE_STRACE_SUPPORT=1 ./b mklx
    ./b mkapps
    ./b mkbr
    ./b bench > $1/lx-13cycles.txt
    LX_THCMP=1 ./b bench > $1/lx-30cycles.txt
else
    GEM5_CP=1 ./b benchgem5 > $1/lx-$LX_ARCH.txt
fi
