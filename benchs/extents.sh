#!/bin/sh

rdcfg=`readlink -f benchs/filereader.cfg`
wrcfg=`readlink -f benchs/filewriter.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

./b

bpe="16 32 64 128 256512 1024 2048"
for b in $bpe; do
    # rebuilding the image is enough
    M3_FSBPE=$b scons build/$M3_TARGET-$M3_BUILD/bench.img
    ./b run $rdcfg -n
    ./src/tools/bench.sh $M3_LOG > $1/m3-fsread-$b.txt

    # change number of blocks we allocate at once
    sed --in-place -e "s/\(WRITE_INC_BLOCKS\s*\)= [[:digit:]]*/\1= $b/" src/include/m3/vfs/RegularFile.h
    # rebuilding filewriter is enough
    scons build/$M3_TARGET-$M3_BUILD/bin/filewriter
    sed --in-place -e 's/\(WRITE_INC_BLOCKS\s*\)= [[:digit:]]*/\1= 1024/' src/include/m3/vfs/RegularFile.h

    ./b run $wrcfg -n
    ./src/tools/bench.sh $M3_LOG > $1/m3-fswrite-$b.txt
done
