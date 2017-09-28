#!/bin/sh

export XTENSA_DIR=/home/hrniels/Applications/xtensa
export GEM5_DIR=/home/hrniels/m3bench/m3/hw/gem5

M3_GEM5_OUT=${M3_GEM5_OUT:-run}

if [ $# -ne 4 ]; then
    echo "Usage: $0 <name> <benchs> <plots> <jobs>" 1>&2
    exit 1
fi

if [ "$M3_TARGET" = "" ]; then
    echo "Please define M3_TARGET first." 1>&2
    exit 1
fi

case $M3_TARGET in
    t3)
        export M3_LOG=run/xtsc.log
        export LX_ARCH=xtensa LX_PLATFORM=xtensa LX_BUILD=release
        ;;
    gem5)
        export M3_LOG=$M3_GEM5_OUT/gem5.log
        export LX_ARCH=x86_64 LX_PLATFORM=gem5 LX_BUILD=release
        ;;
esac

name=$1
benchs=$2
plots=$3

mkdir -p results
res=$(readlink -f results/$name)
mkdir -p $res

for b in $benchs; do
    ./benchs/$b.sh $res $4
done

for p in $plots; do
    ./plots/$p/generate.sh $res
done
