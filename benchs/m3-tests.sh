#!/bin/bash

bootscale=`readlink -f input/bench-scale-pipe.cfg`
bootfstrace=`readlink -f input/fstrace.cfg`
bootimgproc=`readlink -f input/imgproc.cfg`

cfg=`readlink -f input/test-config.py`

. tools/jobs.sh

cd m3
export M3_BUILD=release

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG=$cfg

run_bench() {
    export M3_ISA=$4
    export M3_PETYPE=$3
    export ACCEL_NUM=0
    dirname=m3-tests-$2-$3-$4-$5
    bpe=$5
    export M3_GEM5_OUT=$1/$dirname
    mkdir -p $M3_GEM5_OUT

    bench=$2

    export M3_GEM5_CPU=TimingSimpleCPU
    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ]; then
        export M3_FS=default-$bpe.img
        cp boot/$bench.xml $M3_GEM5_OUT/boot.gen.xml
    else
        export M3_FS=bench-$bpe.img
        if [ "$5" = "64" ]; then
            export M3_GEM5_CPU=DerivO3CPU
        fi
        if [[ "$bench" =~ "bench" ]]; then
            cp boot/$bench.xml $M3_GEM5_OUT/boot.gen.xml
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_ARGS="-i 1 -r 4 -w 1 $writer $reader"
            $bootscale > $M3_GEM5_OUT/boot.gen.xml
        elif [[ "$bench" =~ "imgproc" ]]; then
            IFS='-' read -ra parts <<< "$bench"
            if [ "${parts[1]}" = "indir" ]; then
                export M3_ACCEL_TYPE="indir"
            else
                export M3_ACCEL_TYPE="copy"
            fi
            export M3_ACCEL_COUNT=$((${parts[2]} * 3))
            export M3_ARGS="-m ${parts[1]} -n ${parts[2]} -w 1 -r 4 /large.txt"
            $bootimgproc > $M3_GEM5_OUT/boot.gen.xml
        else
            export M3_ARGS="-n 4 -t -u 1 $bench"
            $bootfstrace > $M3_GEM5_OUT/boot.gen.xml
        fi
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    # set memory and time limits
    ulimit -v 4000000   # 4GB virt mem
    ulimit -t 3600      # 1h CPU time

    ./b run $M3_GEM5_OUT/boot.gen.xml > $M3_GEM5_OUT/output.txt 2>&1

    gzip -f $M3_GEM5_OUT/gem5.log

    if [ $? -eq 0 ] && [ "`grep 'Shutting down' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

for isa in arm x86_64; do
    # build everything
    export M3_ISA=$isa
    ./b || exit 1

    # create FS images
    build=build/$M3_TARGET-$M3_ISA-$M3_BUILD
    for bpe in 16 32 64; do
        $build/tools/mkm3fs $build/bench-$bpe.img $build/fsdata/bench 65536 4096 $bpe
        $build/tools/mkm3fs $build/default-$bpe.img $build/fsdata/default 16384 512 $bpe
    done
done

jobs_init $2

benchs=""
benchs+="rust-unittests rust-benchs unittests cpp-benchs"
benchs+=" bench-netbandwidth bench-netlatency bench-netstream"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
benchs+=" cat_awk cat_wc grep_awk grep_wc"

for bpe in 16 32 64; do
    for isa in arm x86_64; do
        for pe in a b; do
            for test in $benchs; do
                jobs_submit run_bench $1 $test $pe $isa $bpe
            done

            # only 1 chain with indirect, because otherwise we would need more than 16 EPs
            jobs_submit run_bench $1 imgproc-indir-1 $pe $isa $bpe
            for num in 1 2 3 4; do
                jobs_submit run_bench $1 imgproc-dir-$num $pe $isa $bpe
            done
        done
    done
done

jobs_wait
