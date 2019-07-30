#!/bin/bash

root=$(dirname $(readlink -f $0))
cd $root

export M3_TARGET=gem5

branch=cc
if [ $# -gt 0 ]; then
    branch=$1
fi

outname=tests-$(date --iso-8601)
out=results/$outname
mkdir -p $out

echo -e "\033[1mUpdating repositories...\033[0m"
( cd m3 && git checkout $branch && git pull os $branch && git submodule update --recursive ) 2>&1 | tee -a $out/nightly.log
if [ $? -ne 0 ]; then exit 1; fi
( cd m3 && git rev-parse HEAD ) > $out/git-commit

echo -e "\033[1mBuilding gem5...\033[0m"
( cd m3/hw/gem5 && CC=gcc-9 CXX=g++-9 scons -j16 build/{X86,ARM}/gem5.opt ) 2>&1 | tee -a $out/nightly.log
if [ $? -ne 0 ]; then exit 1; fi

echo -e "\033[1mRunning tests...\033[0m"
./run.sh $outname "m3-tests" "" "" 16 2>&1 | tee -a $out/nightly.log

echo -e "\033[1mGenerating report...\033[0m"
./report.py

