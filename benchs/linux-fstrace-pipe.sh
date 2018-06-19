#!/bin/bash

# use this gem5 version, because the atomic rwm operations do not work on the new version
export GEM5_DIR=`readlink -f gem5`

. tools/jobs.sh
. tools/helper.sh

# ( cd xtensa-linux && ./b mklx && ./b mkapps && ./b mkbenchfs )
# [ $? -eq 0 ] || exit 1

export M3_BUILD=release
export GEM5_CPUFREQ=3GHz GEM5_MEMFREQ=1GHz
export GEM5_FLAGS=Dtu

run() {
    /bin/echo -e "\e[1mStarting lx-pipe-fstrace-$2-$6-$7-$8\e[0m"

    jobs_started

    export GEM5_OUT=$1/lx-pipe-fstrace-$2-$6-$7-$8
    mkdir -p $GEM5_OUT

    # 0 = bench
    if [ "$2" = "0" ] || [ "$2" = "1" ] || [ "$2" = "2" ]; then
        count=4
    else
        count=1
    fi
    # 3/4 = strace
    if [ "$2" = "3" ] || [ "$2" = "4" ]; then
        export GEM5_CPU=TimingSimpleCPU
    fi

    export BENCH_CMD="/bench/bin/execpipe $3 $4 $count 1 1 $2 $5"
    ( cd xtensa-linux && GEM5_CP=1 ./b bench &>$GEM5_OUT/output.txt )

    if [ "`grep "^total : " $GEM5_OUT/res.txt | wc -l`" = "$count" ]; then
        /bin/echo -e "\e[1mFinished lx-pipe-fstrace-$2-$6-$7-$8:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished lx-pipe-fstrace-$2-$6-$7-$8:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

gen_results() {
    # generate various files from results
    for no in 3 4; do
        GEM5_OUT=$1/lx-pipe-fstrace-$no-$2-$3-$4
        if [ $no -eq 3 ]; then
            name=$2_$3_$2
        else
            name=$2_$3_$3
        fi
        dst=$1/$name-$4.txt
        echo "Generating $name-$4.txt..."
        cat $1/lx-pipe-fstrace-$no-$2-$3-$4/res.txt | grep -v "^total : " | \
            perl -0777 -pe 's/write\(1,.*?\)\s*=\s*(\d+)/write(1, "", \1) = \1/gs' | \
            perl -0777 -pe 's/serial8250: too much work for irq4\n//gs' > $dst
        echo >> $dst
        echo "===" >> $dst
        cat $1/lx-pipe-fstrace-$((no - 2))-$2-$3-$4/res.txt | grep "^ \[" >> $dst
        gen_timedtrace_pipe $dst 0

        # generate trace.c
        ./m3/build/$M3_TARGET-$LX_ARCH-release/src/apps/fstrace/strace2cpp/strace2cpp $name \
            < $dst-timedstrace \
            > $dst-opcodes.c 2>>$GEM5_OUT/output.txt
        cp $dst-opcodes.c input/trace-$2.c
    done
}

sz=1024

# ( cd m3 && ./b )

# jobs_init $2

# export LX_CORES=2
# for t in 3 4; do
#     jobs_submit run $1 $t 2 3 "/bin/cat /bench/pipedata/${sz}k.txt /usr/bin/awk -f /bench/count-bench.awk" cat awk $sz
#     jobs_submit run $1 $t 3 1 "/bin/grep ipsum /bench/pipedata/${sz}k.txt /usr/bin/wc" grep wc $sz
#     jobs_submit run $1 $t 3 3 "/bin/grep ipsum /bench/pipedata/${sz}k.txt /usr/bin/awk -f /bench/count-bench.awk" grep awk $sz
#     jobs_submit run $1 $t 2 1 "/bin/cat /bench/pipedata/${sz}k.txt /usr/bin/wc" cat wc $sz
# done

# jobs_wait

gen_results $1 cat awk $sz
gen_results $1 grep wc $sz
gen_results $1 grep awk $sz
gen_results $1 cat wc $sz
