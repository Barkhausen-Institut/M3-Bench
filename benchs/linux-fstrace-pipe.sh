#!/bin/bash

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5`

. tools/jobs.sh

cd xtensa-linux
./b mklx && ./b mkapps && ./b mkbenchfs
[ $? -eq 0 ] || exit 1

export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
export GEM5_FLAGS=Dtu

run() {
    /bin/echo -e "\e[1mStarting lx-pipe-fstrace-$2-$6-$7-$8\e[0m"

    jobs_started

    export GEM5_OUT=$1/lx-pipe-fstrace-$2-$6-$7-$8
    mkdir -p $GEM5_OUT

    # 0 = bench
    if [ "$2" = "0" ]; then
        count=4
    else
        count=1
    fi
    # 3/4 = strace
    if [ "$2" = "3" ] || [ "$2" = "4" ]; then
        export GEM5_CPU=TimingSimpleCPU
    fi

    BENCH_CMD="/bench/bin/execpipe $3 $4 $count 1 1 $2 $5" GEM5_CP=1 ./b bench &>$GEM5_OUT/output.txt

    if [ "`grep "^total : " $GEM5_OUT/res.txt | wc -l`" = "$count" ]; then
        /bin/echo -e "\e[1mFinished lx-pipe-fstrace-$2-$6-$7-$8:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-pipe-fstrace-$2-$6-$7-$8:\e[0m \e[1;31mFAILED\e[0m"
    fi

    # split result into strace and timings
    if [ "$2" = "1" ] || [ "$2" = "2" ]; then
        gen_timedtrace $GEM5_OUT/res.txt 3 >> $GEM5_OUT/output.txt 2>&1
    fi
}

jobs_init $2

export LX_CORES=2
sz=1024
for t in 3 4 1 2 0; do
    jobs_submit run $1 $t 2 3 "/bin/cat /bench/pipedata/${sz}k.txt /usr/bin/awk -f /bench/count-bench.awk" cat awk $sz
    jobs_submit run $1 $t 3 1 "/bin/grep ipsum /bench/pipedata/${sz}k.txt /usr/bin/wc" grep wc $sz
    jobs_submit run $1 $t 3 3 "/bin/grep ispum /bench/pipedata/${sz}k.txt /usr/bin/awk -f /bench/count-bench.awk" grep awk $sz
    jobs_submit run $1 $t 2 1 "/bin/cat /bench/pipedata/${sz}k.txt /usr/bin/wc" cat wc $sz
done

jobs_wait
