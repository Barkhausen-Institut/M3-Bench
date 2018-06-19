#!/bin/bash

source tools/helper.sh

# build Linux
export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
( cd xtensa-linux && ./b mklx && ./b mkapps && ./b mkbenchfs )
[ $? -eq 0 ] || exit 1

run_bench() {
    /bin/echo -e "\e[1mStarted lx-srvtrace-$2-trace\e[0m"

    export GEM5_OUT=$1/lx-srvtrace-$2 GEM5_CP=1
    mkdir -p $GEM5_OUT

    # generate strace
    ( cd xtensa-linux && GEM5_CPU=TimingSimpleCPU ./b servertrace ) > $GEM5_OUT/output.txt 2>&1
    mv $GEM5_OUT/res.txt $GEM5_OUT/server-trace.txt

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;31mFAILED\e[0m"
    fi

    /bin/echo -e "\e[1mStarted lx-srvtrace-$2-bench\e[0m"

    # run benchmark
    ( cd xtensa-linux && ./b serverbench ) > $GEM5_OUT/output.txt 2>&1
    mv $GEM5_OUT/res.txt $GEM5_OUT/server-bench.txt

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-$2:\e[0m \e[1;31mFAILED\e[0m"
    fi

    # generate various files from results
    cat $GEM5_OUT/server-trace.txt > $GEM5_OUT/server.txt
    echo >> $GEM5_OUT/server.txt
    echo "===" >> $GEM5_OUT/server.txt
    cat $GEM5_OUT/server-bench.txt >> $GEM5_OUT/server.txt
    gen_timedtrace_server $GEM5_OUT/server.txt 1

    # generate trace.c
    ( cd m3 && M3_BUILD=release ./b )
    ./m3/build/$M3_TARGET-$LX_ARCH-release/src/apps/fstrace/strace2cpp/strace2cpp \
        < $GEM5_OUT/server.txt-timedstrace \
        > $GEM5_OUT/server.txt-opcodes.c
    cp $GEM5_OUT/server.txt-opcodes.c input/trace-$2.c
}

BENCH_CMD="nginx" run_bench $1 nginx
