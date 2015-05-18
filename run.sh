#!/bin/sh

export XTENSA_DIR=/home/hrniels/Applications/xtensa

res=$(readlink -f results/$(date "+%F-%T"))

mkdir -p $res

./benchs/linux.sh $res
./benchs/vpes.sh $res
./benchs/filereader.sh $res
./benchs/filewriter.sh $res

