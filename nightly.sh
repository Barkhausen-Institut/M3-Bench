#!/bin/bash

root=$(dirname $(readlink -f $0))
cd $root

export M3_TARGET=gem5

testgem5=true
testhw=true
branch=dev
force=false
buildgem5=true

while [ $# -gt 0 ]; do
    if [ "$1" = "--skip-hw" ]; then
        testhw=false
    elif [ "$1" = "--skip-gem5" ]; then
        testgem5=false
    elif [ "$1" = "--force" ]; then
        force=true
    elif [ "$1" = "--skip-gem5-build" ]; then
        buildgem5=false
    else
        break
    fi
    shift
done

if [ $# -gt 0 ]; then
    branch=$1
fi

outname=tests-$(date --iso-8601)
out=results/$outname
mkdir -p $out

echo -n > $out/nightly.log

echo -e "\033[1mUpdating repositories...\033[0m"
( cd m3 && git checkout $branch && git pull origin $branch && git submodule update --init --recursive \
  src/m3lx tools/ninjapie cross/buildroot platform/gem5 src/libs/{leveldb,musl,flac} src/apps/bsdutils ) 2>&1 | tee -a $out/nightly.log
if [ $? -ne 0 ]; then exit 1; fi
( cd m3 && git rev-parse HEAD ) > $out/git-commit

# don't re-run the tests with the same commit
if ! $force; then
    for dir in results/tests-*; do
        if [ "$dir" != "$out" ] && cmp $out/git-commit $dir/git-commit &>/dev/null; then
            echo "Current commit $(cat $dir/git-commit) has been already tested in $dir. Exiting." | tee -a $out/nightly.log
    	rm -rf $out
            exit 0
        fi
    done
fi

echo -e "\033[1mStarting garbage collection...\033[0m"
# only keep the last 12 days in full size; reduce the older ones to the minimum
num_days=12
total=$(find results -maxdepth 1 -name "tests-*" -type d | wc -l)
for dir in results/tests-*; do
    if [ $total -le $num_days ]; then
        break
    fi

    echo "$dir: removing unnecessary files and compressing into archive-$dir.tar.xz..."
    # remove everything but the output.txt
    for sub in $dir/*; do
        if [ -d "$sub" ]; then
            find $sub -mindepth 1 -not -name output.txt -print0 | xargs -0 rm -f
        fi
    done

    # pack the output.txt's into an archive
    tar -cf - $dir | xz > results/archive-$(basename $dir).tar.xz
    rm -rf $dir

    total=$((total - 1))
done

if $testgem5; then
    if $buildgem5; then
        echo -e "\033[1mBuilding gem5...\033[0m"
        ( cd m3/platform/gem5 && scons -j16 build/{X86,RISCV}/gem5.opt ) 2>&1 | tee -a $out/nightly.log
        if [ $? -ne 0 ]; then exit 1; fi
    fi

    echo -e "\033[1mRunning tests...\033[0m"
    ./run.sh $outname "m3-tests" "" "" 16 2>&1 | tee -a $out/nightly.log
fi

if $testhw; then
    echo -e "\033[1mRunning hw tests...\033[0m"
    ./run.sh $outname "m3-tests-hw" "" "" 1 2>&1 | tee -a $out/nightly.log
fi

echo -e "\033[1mGenerating code-coverage report...\033[0m"
(
    cd m3
    covfiles=""
    for f in ../$out/m3-tests-*-coverage-riscv-32/coverage-*.profraw; do
        if llvm-profdata-14 show $f >/dev/null; then
            covfiles="$f $covfiles"
        fi
    done
    grcov $covfiles -s . --binary-path build/gem5-riscv-coverage/bin -t html \
        --ignore-not-existing -o ../reports/cov-$(date --iso-8601)
) | tee -a $out/nightly.log

echo -e "\033[1mGenerating report...\033[0m"
./report.py 2>&1 | tee -a $out/nightly.log
