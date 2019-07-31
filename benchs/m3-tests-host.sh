#!/bin/bash

bootscale=`readlink -f input/bench-scale-pipe.cfg`
bootfstrace=`readlink -f input/fstrace.cfg`

lbfile=`readlink -f .lastbuild`

cd m3

echo -n > $lbfile
trap "rm -f $lbfile" EXIT ERR INT TERM

run_bench() {
    export M3_FSBPE=$5

    dirname=m3-tests-$2-$3-$4-$5
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    bench=$2

    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ]; then
        export M3_FS=default.img
        bench=boot/$bench.cfg
    else
        export M3_FS=bench.img

        if [[ "$bench" =~ "bench" ]]; then
            bench=boot/$bench.cfg
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_SCALE_ARGS="-i 1 -r 4 -w 1 $writer $reader"
            bench=$bootscale
        else
            export FSTRACE_ARGS="-n 4 -t -u 1 $bench"
            bench=$bootfstrace
        fi
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"

    if [ "$M3_FSBPE-$M3_BUILD" != "`cat $lbfile`" ]; then
        ./b > $M3_OUT/output.txt 2>&1 || exit
        echo -n $M3_FSBPE-$M3_BUILD > $lbfile
    fi

    /bin/echo -e "\e[1mStarted $dirname\e[0m"

    ./b run $bench -n >> $M3_OUT/output.txt 2>&1

    if [ $? -eq 0 ] && [ "`grep 'Shutting down' $M3_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

export M3_TARGET=host
./b || exit 1

benchs=""
benchs+="rust-unittests rust-benchs unittests cpp-benchs"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
benchs+=" cat_awk cat_wc grep_awk grep_wc"

for bpe in 2 4 8 16 32 64; do
    for build in debug release; do
        export M3_BUILD=$build

        for test in $benchs; do
            run_bench $1 $test host-$build x86_64 $bpe
        done
    done
done
