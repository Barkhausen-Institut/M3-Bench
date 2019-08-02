#!/bin/bash

root=$(dirname $(readlink -f $0))
cd $root

export M3_TARGET=gem5

branch=dev
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

# don't re-run the tests with the same commit
for dir in results/tests-*; do
    if [ "$dir" != "$out" ] && cmp $out/git-commit $dir/git-commit &>/dev/null; then
        echo "Current commit $(cat $dir/git-commit) has been already tested in $dir. Exiting." | tee -a $out/nightly.log
        exit 1
    fi
done

echo -e "\033[1mStarting garbage collection...\033[0m"
# only keep the last 7 days in full size; reduce the older ones to the minimum
num_days=7
total=$(find results -maxdepth 1 -name "tests-*" -type d | wc -l)
for dir in results/tests-*; do
    if [ $total -le $num_days ]; then
        break
    fi

    echo "$dir: removing unnecessary files and compressing into archive-$dir.tar.xz..."
    # remove everything but the output.txt
    for sub in $dir/*; do
        if [ -d $sub ]; then
            find $sub -mindepth 1 -not -name output.txt -print0 | xargs -0 rm -f
        fi
    done

    # pack the output.txt's into an archive
    tar cf - $dir | xz > archive-$dir.tar.xz
    rm -rf $dir

    total=$((total - 1))
done

echo -e "\033[1mBuilding gem5...\033[0m"
( cd m3/hw/gem5 && CC=gcc-9 CXX=g++-9 scons -j16 build/{X86,ARM}/gem5.opt ) 2>&1 | tee -a $out/nightly.log
if [ $? -ne 0 ]; then exit 1; fi

echo -e "\033[1mRunning tests...\033[0m"
./run.sh $outname "m3-tests" "" "" 16 2>&1 | tee -a $out/nightly.log

echo -e "\033[1mRunning host tests...\033[0m"
./run.sh $outname "m3-tests-host" "" "" 1 2>&1 | tee -a $out/nightly.log

echo -e "\033[1mGenerating report...\033[0m"
./report.py
