#!/bin/bash

inputdir=`readlink -f input`

. tools/jobs.sh

cd m3

export M3_TARGET=gem5
if [ -z $M3_GEM5_DBG ]; then
	export M3_GEM5_DBG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG=$inputdir/test-config.py

run_bench() {
    export M3_ISA=$4
    export M3_PETYPE=$3
    export ACCEL_NUM=0
    dirname=m3-tests-$2-$3-$4-$5
    bpe=$5
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    bootprefix=""
    if [ "$3" = "sh" ]; then
        export M3_PETYPE=b
        bootprefix="shared/"
    fi

    bench=$2

    export M3_GEM5_CPU=TimingSimpleCPU
    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ] || [ "$bench" = "hello" ] ||
        [ "$bench" = "rust-net-tests" ] || [ "$bench" = "cpp-net-tests" ]; then
        export M3_FS=default-$bpe.img
        cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
        if [ "$bench" = "hello" ]; then
            export M3_BUILD=debug
        fi
    elif [ "$bench" = "standalone" ]; then
        export M3_CORES=8
        export M3_GEM5_CFG=config/spm.py
        cp boot/kachel/$bench.xml $M3_OUT/boot.gen.xml
    elif [ "$bench" = "libctest" ]; then
        export M3_FS=default-$bpe.img
        cp boot/kachel/$bench.xml $M3_OUT/boot.gen.xml
    elif [ "$bench" = "disk-test" ]; then
        export M3_HDD=$inputdir/test-hdd.img
        cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
    elif [ "$bench" = "abort-test" ]; then
        export M3_GEM5_CFG=config/aborttest.py
        cp boot/hello.xml $M3_OUT/boot.gen.xml
    else
        export M3_FS=bench-$bpe.img
        if [ "$5" = "64" ]; then
            export M3_GEM5_CPU=DerivO3CPU
        fi
        if [[ "$bench" =~ "bench" ]]; then
            cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_ARGS="-d -i 1 -r 4 -w 1 $writer $reader"
            $inputdir/${bootprefix}bench-scale-pipe.cfg > $M3_OUT/boot.gen.xml
        elif [[ "$bench" =~ "imgproc" ]]; then
            IFS='-' read -ra parts <<< "$bench"
            if [ "${parts[1]}" = "indir" ]; then
                export M3_ACCEL_TYPE="indir"
            else
                export M3_ACCEL_TYPE="copy"
            fi
            export M3_ACCEL_COUNT=$((${parts[2]} * 3))
            export M3_ARGS="-m ${parts[1]} -n ${parts[2]} -w 1 -r 4 /large.txt"
            $inputdir/${bootprefix}imgproc.cfg > $M3_OUT/boot.gen.xml
        else
            export M3_ARGS="-n 4 -t -d -u 1 $bench"
            $inputdir/${bootprefix}fstrace.cfg > $M3_OUT/boot.gen.xml
        fi
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    # set memory and time limits
    ulimit -v 5000000   # 5GB virt mem
    ulimit -t 900       # 15min CPU time

    ./b run $M3_OUT/boot.gen.xml -n > $M3_OUT/output.txt 2>&1

    gzip -f $M3_OUT/gem5.log

    if [ $? -eq 0 ] && ../tools/check_result.py $M3_OUT/output.txt 2>/dev/null; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

build_types="debug release"
build_isas="riscv arm x86_64"
run_isas="riscv arm x86_64"

if [ "$M3_TEST" != "" ]; then
    test_args=$(python -c '
import sys
p = sys.argv[1].split("-")
if len(p) < 4:
    sys.exit(1)
print("{} {} {} {}".format("-".join(p[:-3]), p[-3], p[-2], p[-1]))
' $M3_TEST) || ( echo "Please set M3_TEST to <bench>-<pe>-<isa>-<bpe>." && exit 1 )
fi

if [ "$M3_TEST" != "" ]; then
    build_isas=$(echo $test_args | cut -d ' ' -f 3)
    if [[ $M3_TEST == hello-* ]]; then
        build_types="debug"
    else
        build_types="release"
    fi
fi

for btype in $build_types; do
    for isa in $build_isas; do
        # build everything
        export M3_ISA=$isa
        M3_BUILD=$btype ./b || exit 1

        # create FS images
        build=build/$M3_TARGET-$M3_ISA-$btype
        for bpe in 16 32 64; do
            $build/tools/mkm3fs $build/bench-$bpe.img $build/src/fs/bench 65536 4096 $bpe
            $build/tools/mkm3fs $build/default-$bpe.img $build/src/fs/default 16384 512 $bpe
        done
   done
done

jobs_init $2

export M3_BUILD=release

# run a single test?
if [ "$M3_TEST" != "" ]; then
    jobs_submit run_bench $1 $test_args
    jobs_wait
    exit 0
fi

benchs=""
benchs+="rust-unittests rust-benchs unittests cpp-benchs"
benchs+=" rust-net-tests cpp-net-tests rust-net-benchs cpp-net-benchs"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
benchs+=" cat_awk cat_wc grep_awk grep_wc"
benchs+=" disk-test abort-test"
benchs+=" standalone libctest"
# only 1 chain with indirect, because otherwise we would need more than 16 EPs
benchs+=" imgproc-indir-1"
for num in 1 2 3 4; do
    benchs+=" imgproc-dir-$num"
done

# run user-specified tests?
if [ "$M3_TESTS" != "" ]; then
    benchs="$M3_TESTS"
fi

for bpe in 32 64; do
    for isa in $run_isas; do
        for pe in a b sh; do
            for test in $benchs; do
                # standalone works only with SPM
                if [ "$test" = "standalone" ] && [ "$pe" != "a" ]; then
                    continue;
                fi

                jobs_submit run_bench $1 $test $pe $isa $bpe
            done
        done
    done
done

jobs_wait

