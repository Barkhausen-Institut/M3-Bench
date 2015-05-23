#!/bin/sh

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench

./b run ../../filereader.cfg
./tools/bench.sh xtsc.log > $1/m3-fsread.txt

./b run boot/filewriter.cfg
./tools/bench.sh xtsc.log > $1/m3-fswrite.txt
