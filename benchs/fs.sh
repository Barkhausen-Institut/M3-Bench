#!/bin/sh


rdcfg=`readlink -f benchs/fs/filereader.cfg`
wrcfg=`readlink -f benchs/fs/filewriter.cfg`

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench

./b run $rdcfg
./tools/bench.sh xtsc.log > $1/m3-fsread.txt

./b run $wrcfg
./tools/bench.sh xtsc.log > $1/m3-fswrite.txt
