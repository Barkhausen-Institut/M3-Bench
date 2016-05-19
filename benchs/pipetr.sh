#!/bin/sh

cd m3
export M3_BUILD=bench M3_FS=bench.img

./b run boot/pipetr.cfg
./src/tools/bench.sh $M3_LOG > $1/m3-pipetr.txt
