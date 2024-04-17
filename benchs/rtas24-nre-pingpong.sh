#!/bin/bash

set -e

rm -rf /tmp/nre-cross-x86_64
tar xfvJ nre-cross-arch-x86_64-x86_64.tar.xz -C /

cd NRE/nre

dirname="nre-ipc-gem5"
export GEM5=1 GEM5_OUT="$1/$dirname"
export NRE_TARGET=x86_64 NRE_BUILD=release

mkdir -p "$GEM5_OUT"

# rebuild nova to ensure that the GEM5 define is considered
( cd ../kernel/nova/build && ARCH=$NRE_TARGET make clean )
./b

/bin/echo -e "\e[1mStarting $dirname\e[0m"

./b gem5 boot/test -n 2> "$GEM5_OUT/logerr.txt"

if [ "$(grep 'Total failures: 0' "$GEM5_OUT/system.pc.com_1.device")" != "" ]; then
    /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
else
    /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
fi
