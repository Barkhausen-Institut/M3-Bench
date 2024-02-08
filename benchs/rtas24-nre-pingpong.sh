#!/bin/sh

set -e

cd NRE/nre

export GEM5=1 GEM5_OUT="$1/nre-ipc-gem5"
export NRE_TARGET=x86_64 NRE_BUILD=release

mkdir -p "$GEM5_OUT"

# rebuild nova to ensure that the GEM5 define is considered
( cd ../kernel/nova/build && ARCH=$NRE_TARGET make clean )

./b gem5 boot/test

