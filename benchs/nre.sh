#!/bin/sh

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=$(readlink -f gem5-official)
export GEM5_OUT="$1"

cd NRE/nre

NRE_TARGET=x86_64 NRE_BUILD=release ./b gem5 boot/test
