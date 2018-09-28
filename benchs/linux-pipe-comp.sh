#!/bin/bash

. tools/jobs.sh

extract_results() {
    awk '/>===.*/ {
        capture = 1
    }
    /<===.*/ {
        capture = 0
    }
    /^[^<>].*/ {
        if(capture == 1)
            print $0
    }'
}

cd xtensa-linux

./b mkapps
./b mklx
./b mkbenchfs

run() {
    /bin/echo -e "\e[1mStarting $3\e[0m"

    jobs_started

    mkdir -p $1/lx-$3
    BENCH_CMD="$2" GEM5_OUT=$1/lx-$3 GEM5_CP=1 LX_CORES=2 ./b bench 1>/dev/null 2>/dev/null

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished $3:\e[0m \e[1;32mSUCCESS\e[0m"
        extract_results < $1/lx-$3/res.txt > $1/lx-$3-output.txt
    else
        /bin/echo -e "\e[1mFinished $3:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init $2

datasize=$((512 * 1024))
wr=/bench/bin/pipewr
rd=/bench/bin/piperd

for comp in 32 64 128 256 512; do
    for per in 100 500 750 1000; do
        slow=$(($comp * 1000))
        fast=$(($comp * $per))
        jobs_submit run $1 "/bench/bin/execpipe 3 2 4 1 1 0 $wr $datasize $slow $rd $fast" "read-$per-$comp"
        jobs_submit run $1 "/bench/bin/execpipe 3 2 4 1 1 0 $wr $datasize $fast $rd $slow" "write-$per-$comp"
    done
done

jobs_wait
