#!/bin/sh

export XTENSA_DIR=/home/hrniels/Applications/xtensa

now=$(date "+%F-%T")

mkdir -p results
res=$(readlink -f results/$now)
mkdir -p $res

benchs="linux vpes filereader filewriter"
for b in $benchs; do
    ./benchs/$b.sh $res
done

plots="basic"
for p in $plots; do
    ./plots/$p/generate.sh $res
done
