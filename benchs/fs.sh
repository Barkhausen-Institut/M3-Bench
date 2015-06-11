#!/bin/sh

rdcfg=`readlink -f benchs/filereader.cfg`
wrcfg=`readlink -f benchs/filewriter.cfg`
cpcfg=`readlink -f benchs/filecopy.cfg`

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench M3_FS=bench.img

./b run $rdcfg
./tools/bench.sh xtsc.log > $1/m3-fsread.txt

./b run $wrcfg
./tools/bench.sh xtsc.log > $1/m3-fswrite.txt

./b run $cpcfg
./tools/bench.sh xtsc.log > $1/m3-fscopy.txt

# ensure that we don't let reader and writer run in parallel
sed --in-place -e 's/#if defined(__t2__)/#if defined(__t2__) || defined(__t3__)/' include/m3/pipe/Pipe.h

# build everything and undo the changes
./b

sed --in-place -e 's/#if defined(__t2__) || defined(__t3__)/#if defined(__t2__)/' include/m3/pipe/Pipe.h

./b run boot/bench-pipe.cfg -n
./tools/bench.sh xtsc.log > $1/m3-pipe.txt
