#!/bin/sh

cd NRE/nre

NRE_TARGET=x86_64 NRE_BUILD=release ./b gem5 boot/test

if [ $? -eq 0 ]; then
    log=m5out/system.pc.com_1.terminal

    grep -P '! PingpongXPd\.cc.* \d+ cycles' $log | sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/' \
        > $1/nre-ipc.txt
    grep -P '! Syscall\.cc.* \d+ cycles' $log | sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/' \
        > $1/nre-syscall.txt
fi
