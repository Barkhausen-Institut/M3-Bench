#!/bin/bash

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5`

. tools/jobs.sh

cd xtensa-linux

./b mkapps
./b mklx
./b mkbr

export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
export GEM5_FLAGS=Dtu

run() {
    /bin/echo -e "\e[1mStarting lx-pipe-ctx-$3-$4-$5\e[0m"

    jobs_started

    export GEM5_OUT=$1/lx-pipe-ctx-$3-$4-$5
    mkdir -p $GEM5_OUT

    BENCH_CMD="$2" GEM5_CP=1 ./b bench 1>/dev/null 2>/dev/null

    if [ "`grep "^total : " $GEM5_OUT/res.txt | wc -l`" = "4" ]; then
        /bin/echo -e "\e[1mFinished lx-pipe-ctx-$3-$4-$5:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-pipe-ctx-$3-$4-$5:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init $2

export LX_CORES=2
for sz in 512 1024 2048 4096; do
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/rand $(($sz * 1024)) /bench/bin/wc" rand wc $sz
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/cat /bench/pipedata/${sz}k.txt /bench/bin/wc" cat wc $sz
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/rand $(($sz * 1024)) /bench/bin/sink" rand sink $sz
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/cat /bench/pipedata/${sz}k.txt /bench/bin/sink" cat sink $sz
done

export LX_CORES=1
for sz in 512 1024 2048 4096; do
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/rand $(($sz * 1024)) /bench/bin/wc" 1pe-rand wc $sz
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/cat /bench/pipedata/${sz}k.txt /bench/bin/wc" 1pe-cat wc $sz
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/rand $(($sz * 1024)) /bench/bin/sink" 1pe-rand sink $sz
    jobs_submit run $1 "/bench/bin/execpipe 2 1 4 1 1 /bench/bin/cat /bench/pipedata/${sz}k.txt /bench/bin/sink" 1pe-cat sink $sz
done

jobs_wait
