#!/bin/bash

cd xtensa-linux

./b mklx
./b mkapps
./b mkbr

if [ "$LX_ARCH" != "xtensa" ]; then
    # remove old checkpoints
    rm -rf gem5/cpt.*
    # create checkpoint
    GEM5_CPU=TimingSimpleCPU ./b warmup
fi
