#!/bin/sh

. tools/jobs.sh

rdcfg=`readlink -f input/filereader.cfg`
wrcfg=`readlink -f input/filewriter.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
export M3_CORES=3
# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    /bin/echo -e "\e[1mStarting m3-extents-$2-$3\e[0m"

    export M3_GEM5_OUT=$1/m3-extents-$2-$3
    mkdir -p $M3_GEM5_OUT

    if [ "$2" = "rd" ]; then
        # rebuilding the image is enough
        M3_FSBPE=$3 M3_VERBOSE=1 scons build/$M3_TARGET-$LX_ARCH-$M3_BUILD/bench.img > $M3_GEM5_OUT/output.txt 2>&1
        [ $? -eq 0 ] || ( jobs_started && exit 1 )

        ./b run $rdcfg -n >> $M3_GEM5_OUT/output.txt 2>&1 &
    else
        # change number of blocks we allocate at once
        sed --in-place -e "s/\(WRITE_INC_BLOCKS\s*\)= [[:digit:]]*/\1= $3/" src/include/m3/vfs/RegularFile.h
        # rebuilding filewriter is enough
        scons build/$M3_TARGET-$LX_ARCH-$M3_BUILD/bin/filewriter > $M3_GEM5_OUT/output.txt 2>&1
        res=$?
        sed --in-place -e 's/\(WRITE_INC_BLOCKS\s*\)= [[:digit:]]*/\1= 1024/' src/include/m3/vfs/RegularFile.h
        [ $res -eq 0 ] || ( jobs_started && exit 1 )

        ./b run $wrcfg -n >> $M3_GEM5_OUT/output.txt 2>&1 &
    fi

    # wait until gem5 has started the simulation
    while [ "`grep 'info: Entering event queue' $M3_GEM5_OUT/output.txt`" = "" ]; do
        sleep 1
    done

    jobs_started

    /bin/echo -e "\e[1mStarted m3-extents-$2-$3\e[0m"

    wait

    if [ $? -eq 0 ] && [ "`grep '\(Read\|Write\) time:' $M3_GEM5_OUT/output.txt`" != "" ]; then
        /bin/echo -e "\e[1mFinished m3-extents-$2-$3:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-extents-$2-$3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

./b

jobs_init $2

bpe="16 32 64 128 256 512"
for b in $bpe; do
    jobs_submit run_bench $1 rd $b
done
for b in $bpe; do
    jobs_submit run_bench $1 wr $b
done

jobs_wait
