#!/bin/bash

inputdir=`readlink -f input`

cd m3

export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1

run_bench() {
    bpe=$6
    dirname=m3-tests-$2-$3-$4-$5-$6
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    bootprefix=""
    if [ "$4" = "sh" ]; then
        bootprefix="shared/"
    fi

    bench=$2

    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ]; then
        export M3_FS=default-$bpe.img
        cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
    elif [ "$bench" = "standalone" ] || [ "$bench" = "memtest" ] || [ "$bench" = "standalone-sndrcv" ]; then
        export M3_HW_VM=0
        cp boot/kachel/$bench.xml $M3_OUT/boot.gen.xml
    elif [ "$bench" = "hello" ]; then
        cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
    else
        export M3_FS=bench-$bpe.img

        if [[ "$bench" =~ "bench" ]]; then
            cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_ACCEL_COUNT=0 M3_ARGS="-i 1 -r 2 -w 1 $writer $reader"
            $inputdir/${bootprefix}bench-scale-pipe.cfg > $M3_OUT/boot.gen.xml
        else
            export M3_ARGS="-n 4 -t -u 1 $bench"
            $inputdir/${bootprefix}fstrace.cfg > $M3_OUT/boot.gen.xml
        fi
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"

    ./b run $M3_OUT/boot.gen.xml -n > $M3_OUT/output.txt 2>&1

    if [ $? -eq 0 ] && ../tools/check_result.py $M3_OUT/output.txt 2>/dev/null; then
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
    build=build/$M3_TARGET-$M3_ISA-$M3_BUILD
    for bpe in 32 64; do
        $build/tools/mkm3fs $build/bench-$bpe.img $build/src/fs/bench $((64 * 1024)) 4096 $bpe
        $build/tools/mkm3fs $build/default-$bpe.img $build/src/fs/default $((16 * 1024)) 512 $bpe
    done
done

benchs=""
benchs+="rust-unittests rust-benchs unittests cpp-benchs"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
benchs+=" cat_awk cat_wc grep_awk grep_wc"
benchs+=" standalone memtest standalone-sndrcv"
benchs+=" hello"

# run user-specified tests?
if [ "$M3_TESTS" != "" ]; then
    benchs="$M3_TESTS"
fi

for bpe in 32 64; do
    for build in debug release; do
        for ty in ex sh; do
            # the *-64 runs are for performance, so don't run in debug mode
            if [ $bpe -eq 64 ] && [ "$build" = "debug" ]; then
                continue;
            fi

            export M3_BUILD=$build

            for test in $benchs; do
                run_bench $1 $test hw-$build $ty $M3_ISA $bpe
            done
        done
    done
done
