#!/bin/bash

bootscale=`readlink -f input/bench-scale-pipe.cfg`
bootfstrace=`readlink -f input/fstrace.cfg`

cd m3

export M3_TARGET=host

run_bench() {
    bpe=$5
    dirname=m3-tests-$2-$3-$4-$5
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    bench=$2

    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ]; then
        export M3_FS=default-$bpe.img
        cp boot/$bench.xml $M3_OUT/boot.gen.xml
    else
        export M3_FS=bench-$bpe.img

        if [[ "$bench" =~ "bench" ]]; then
            cp boot/$bench.xml $M3_OUT/boot.gen.xml
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_ACCEL_COUNT=0 M3_ARGS="-i 1 -r 4 -w 1 $writer $reader"
            $bootscale > $M3_OUT/boot.gen.xml
        else
            export M3_ARGS="-n 4 -t -u 1 $bench"
            $bootfstrace > $M3_OUT/boot.gen.xml
        fi
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"

    ./b run $M3_OUT/boot.gen.xml -n > $M3_OUT/output.txt 2>&1

    if [ $? -eq 0 ] && [ "`grep 'Shutting down' $M3_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

for btype in debug release; do
    # build everything
    export M3_BUILD=$btype
    ./b || exit 1

    # create FS images
    build=build/$M3_TARGET-x86_64-$M3_BUILD
    for bpe in 16 32 64; do
        $build/tools/mkm3fs $build/bench-$bpe.img $build/fsdata/bench $((160 * 1024)) 4096 $bpe
        $build/tools/mkm3fs $build/default-$bpe.img $build/fsdata/default $((160 * 1024)) 512 $bpe
    done
done

benchs=""
benchs+="rust-unittests rust-benchs unittests cpp-benchs"
benchs+=" bench-netlatency bench-netbandwidth bench-netstream"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
benchs+=" cat_awk cat_wc grep_awk grep_wc"

for bpe in 16 32 64; do
    for build in debug release; do
        export M3_BUILD=$build

        for test in $benchs; do
            run_bench $1 $test host-$build x86_64 $bpe
        done
    done
done
