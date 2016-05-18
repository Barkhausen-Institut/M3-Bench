#!/bin/sh

export XTENSA_DIR=/home/hrniels/Applications/xtensa
export GEM5_DIR=/home/hrniels/imdata/gem5-current

if [ $# -ne 3 ]; then
    echo "Usage: $0 <name> <benchs> <plots>" 1>&2
    exit 1
fi

if [ "$M3_TARGET" = "" ]; then
    echo "Please define M3_TARGET first." 1>&2
    exit 1
fi

case $M3_TARGET in
    t3)
        export M3_LOG=run/xtsc.log
        ;;
    gem5)
        export M3_LOG=run/gem5.log
        ;;
esac

name=$1
benchs=$2
plots=$3

mkdir -p results
res=$(readlink -f results/$name)
mkdir -p $res

for b in $benchs; do
    ./benchs/$b.sh $res
done

for p in $plots; do
    ./plots/$p/generate.sh $res
done
