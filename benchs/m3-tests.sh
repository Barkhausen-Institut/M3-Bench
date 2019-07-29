#!/bin/bash

bootscale=`readlink -f input/bench-scale-pipe.cfg`
bootfstrace=`readlink -f input/fstrace.cfg`
bootimgproc=`readlink -f input/imgproc.cfg`
cfgimgproc=`readlink -f input/config-imgproc.py`
lbfile=`readlink -f .lastbuild`

. tools/jobs.sh

cd m3
export M3_BUILD=release

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12

echo -n > $lbfile
trap "rm -f $lbfile" EXIT ERR INT TERM

run_bench() {
    export M3_FSBPE=$5
    export M3_ISA=$4
    dirname=m3-tests-$2-$3-$4-$5
    export M3_GEM5_OUT=$1/$dirname
    mkdir -p $M3_GEM5_OUT

    bench=$2

    if [ "$3" = "a" ]; then
        export M3_GEM5_CFG=config/spm.py
    elif [ "$3" = "b" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=0 M3_GEM5_DTUPOS=0
    elif [ "$3" = "c" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
    fi

    export M3_GEM5_CPU=TimingSimpleCPU
    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ]; then
        export M3_FS=default.img
        bench=boot/$bench.cfg
    else
        export M3_FS=bench.img
        if [ "$5" = "64" ]; then
            export M3_GEM5_CPU=DerivO3CPU
        fi
        if [[ "$bench" =~ "bench" ]]; then
            bench=boot/$bench.cfg
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_SCALE_ARGS="-i 1 -r 4 -w 1 $writer $reader"
            bench=$bootscale
        elif [[ "$bench" =~ "imgproc" ]]; then
            IFS='-' read -ra parts <<< "$bench"
            export ACCEL_NUM=$((${parts[2]} * 3)) ACCEL_PCIE=0
            export M3_IMGPROC_ARGS="-m ${parts[1]} -n ${parts[2]} -w 1 -r 4 /large.txt"
            export M3_GEM5_CFG=$cfgimgproc
            bench=$bootimgproc
        else
            export FSTRACE_ARGS="-n 4 -t -u 1 $bench"
            bench=$bootfstrace
        fi
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"

    if [ "$M3_FSBPE-$M3_ISA" != "`cat $lbfile`" ]; then
        ./b 2>&1 > $M3_GEM5_OUT/output.txt || exit
        echo -n $M3_FSBPE-$M3_ISA > $lbfile
    fi

    /bin/echo -e "\e[1mStarted $dirname\e[0m"
    jobs_started

    # set memory and time limits
    ulimit -v 4000000   # 4GB virt mem
    ulimit -t 3600      # 1h CPU time

    ./b run $bench -n >> $M3_GEM5_OUT/output.txt

    gzip -f $M3_GEM5_OUT/gem5.log

    if [ $? -eq 0 ] && [ "`grep 'Shutting down' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

benchs=""
benchs+="rust-unittests rust-benchs unittests cpp-benchs"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
benchs+=" cat_awk cat_wc grep_awk grep_wc"

for bpe in 2 4 8 16 32 64; do
    for isa in arm x86_64; do
        for pe in a b c; do
            if [ "$isa" = "arm" ] && [ "$pe" = "c" ]; then
                continue;
            fi

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
