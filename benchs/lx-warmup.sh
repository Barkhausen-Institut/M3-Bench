#!/bin/bash

if [ "$LX_CORES" = "" ]; then
    echo "Please specify LX_CORES!" >&2
    exit 1
fi

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5`

cd xtensa-linux

./b mklx
./b mkapps
./b mkbr

# remove old checkpoints
rm -rf gem5-$LX_CORES/cpt.*
# create checkpoint
GEM5_CPU=TimingSimpleCPU ./b warmup
