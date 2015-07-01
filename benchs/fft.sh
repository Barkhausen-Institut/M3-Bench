#!/bin/sh

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench

# ensure that we don't let reader and writer run in parallel
sed --in-place -e 's/#if defined(__t2__)/#if defined(__t2__) || defined(__t3__)/' include/m3/pipe/Pipe.h

# build everything and undo the changes
./b

sed --in-place -e 's/#if defined(__t2__) || defined(__t3__)/#if defined(__t2__)/' include/m3/pipe/Pipe.h

./b run boot/fft.cfg -n
./tools/bench.sh xtsc.log > $1/m3-fft.txt

./b run boot/ffttie.cfg -n
./tools/bench.sh xtsc.log > $1/m3-ffttie.txt
