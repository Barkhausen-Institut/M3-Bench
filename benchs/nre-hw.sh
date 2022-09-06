#!/bin/sh

cd NRE/nre

export NRE_TARGET=x86_64 NRE_BUILD=release
export GEM5=0

# rebuild nova to ensure that the GEM5 define is considered
( cd ../kernel/nova/build && ARCH=$NRE_TARGET make clean )

 ./b

# copy all files to bitest
./boot/unittests --server=bios:tftpboot --build-dir=build/x86_64-release --grub-prefix="(nd)/nils"

# now wait for the results from serial line
echo -n > "$1/log.txt"
minicom -D /dev/ttyUSB0 -C "$1/log.txt"
