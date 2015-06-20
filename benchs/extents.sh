#!/bin/sh

rdcfg=`readlink -f benchs/filereader.cfg`
wrcfg=`readlink -f benchs/filewriter.cfg`

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench M3_FS=bench.img

bpe="16 32 64 128 256 512 1024 2048"
for b in $bpe; do
    M3_FSBPE=$b ./b run $rdcfg
    ./tools/bench.sh xtsc.log > $1/m3-fsread-$b.txt

    # change number of blocks we allocate at once
    sed --in-place -e "s/\(WRITE_INC_BLOCKS\s*\)= [[:digit:]]*/\1= $b/" include/m3/vfs/RegularFile.h
    ./b
    sed --in-place -e 's/\(WRITE_INC_BLOCKS\s*\)= [[:digit:]]*/\1= 1024/' include/m3/vfs/RegularFile.h

    ./b run $wrcfg -n
    ./tools/bench.sh xtsc.log > $1/m3-fswrite-$b.txt
done
