#!/bin/sh

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5`

cd NRE/nre

NRE_TARGET=x86_64 NRE_BUILD=release ./b gem5 boot/test

if [ $? -eq 0 ]; then
    mkdir -p $1/nre
    cp m5out/system.pc.com_1.terminal $1/nre/gem5.log
fi
