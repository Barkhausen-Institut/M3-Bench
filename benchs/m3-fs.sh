#!/bin/bash

. tools/jobs.sh

rdcfg=`readlink -f input/filereader.cfg`
wrcfg=`readlink -f input/filewriter.cfg`
cpcfg=`readlink -f input/filecopy.cfg`

cd m3
export M3_BUILD=release

export M3_FS=bench.img
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=3

# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    export M3_FSBPE=$6
    export M3_GEM5_OUT=$1/m3-fs-$2-$5-$6
    mkdir -p $M3_GEM5_OUT

    if [ "$5" = "a" ]; then
        export M3_GEM5_CFG=config/spm.py
    elif [ "$5" = "b" ]; then
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=0 M3_GEM5_DTUPOS=0
    else
        export M3_GEM5_CFG=config/caches.py
        export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
    fi
    export M3_REPEATS=$7
    export M3FS_ARGS="-e $M3_FSBPE $3"

    /bin/echo -e "\e[1mStarting m3-fs-$2-$5-$6\e[0m"

    # rebuilding the image is enough
    scons build/$M3_TARGET-$LX_ARCH-$M3_BUILD/bench.img > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || ( jobs_started && exit 1 )

    ./b run $4 -n >> $M3_GEM5_OUT/output.txt 2>&1 &

    # wait until gem5 has started the simulation
    while [ "`grep 'info: Entering event queue' $M3_GEM5_OUT/output.txt`" = "" ]; do
        sleep 1
    done

    jobs_started

    /bin/echo -e "\e[1mStarted m3-fs-$2-$5-$6\e[0m"

    wait

    if [ $? -eq 0 ] && [ "`grep '\(Read\|Write\|Copy\) time:' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-fs-$2-$5-$6:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-fs-$2-$5-$6:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b || exit 1

jobs_init $2

for bpe in 2 4 8 16 32 64 128 256; do
    jobs_submit run_bench $1 read "" $rdcfg a $bpe 1
    jobs_submit run_bench $1 write "" $wrcfg a $bpe 1
    jobs_submit run_bench $1 write-clear "-c" $wrcfg a $bpe 1
    jobs_submit run_bench $1 copy "" $cpcfg a $bpe 1
done

bpe=64
for pe in a b c; do
    jobs_submit run_bench $1 read "-r" $rdcfg $pe $bpe 5
    jobs_submit run_bench $1 write "-r" $wrcfg $pe $bpe 5
    jobs_submit run_bench $1 write-clear "-c -r" $wrcfg $pe $bpe 5
    jobs_submit run_bench $1 copy "-r" $cpcfg $pe $bpe 5
done

jobs_wait
