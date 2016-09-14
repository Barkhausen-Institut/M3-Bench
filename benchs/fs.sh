#!/bin/sh

rdcfg=`readlink -f input/filereader.cfg`
wrcfg=`readlink -f input/filewriter.cfg`
cpcfg=`readlink -f input/filecopy.cfg`
pipedir=`readlink -f input/pipe-direct.cfg`
pipeindir=`readlink -f input/pipe-indirect.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

./b run $rdcfg
./src/tools/bench.sh $M3_LOG > $1/m3-fsread.txt

./b run $wrcfg
./src/tools/bench.sh $M3_LOG > $1/m3-fswrite.txt

./b run $cpcfg
./src/tools/bench.sh $M3_LOG > $1/m3-fscopy.txt

# rebuild bench-pipe so that reader/writer are forced to take turns
M3_CFLAGS="-DSINGLE_ITEM_BUF=1" scons build/$M3_TARGET-$M3_BUILD/bin/bench-pipe

./b run $pipedir -n
./src/tools/bench.sh $M3_LOG > $1/m3-pipe-direct.txt

./b run $pipeindir -n
./src/tools/bench.sh $M3_LOG > $1/m3-pipe-indirect.txt
