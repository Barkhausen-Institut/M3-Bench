#!/bin/sh

rdcfg=`readlink -f benchs/filereader.cfg`
wrcfg=`readlink -f benchs/filewriter.cfg`
cpcfg=`readlink -f benchs/filecopy.cfg`
pipedir=`readlink -f benchs/pipe-direct.cfg`
pipeindir=`readlink -f benchs/pipe-indirect.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

./b run $rdcfg
./src/tools/bench.sh $M3_LOG > $1/m3-fsread.txt

./b run $wrcfg
./src/tools/bench.sh $M3_LOG > $1/m3-fswrite.txt

./b run $cpcfg
./src/tools/bench.sh $M3_LOG > $1/m3-fscopy.txt

# ensure that we don't let reader and writer run in parallel
sed --in-place -e 's/#if defined(__t2__)/#if defined(__t2__) || defined(__t3__)/' src/include/m3/pipe/DirectPipe.h

# build bench-pipe and undo the changes
scons build/$M3_TARGET-$M3_BUILD/bin/bench-pipe

sed --in-place -e 's/#if defined(__t2__) || defined(__t3__)/#if defined(__t2__)/' src/include/m3/pipe/DirectPipe.h

./b run $pipedir -n
./src/tools/bench.sh $M3_LOG > $1/m3-pipe-direct.txt

./b run $pipeindir
./src/tools/bench.sh $M3_LOG > $1/m3-pipe-indirect.txt
