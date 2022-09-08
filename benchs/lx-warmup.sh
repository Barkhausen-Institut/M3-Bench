#!/bin/bash

. tools/jobs.sh

export GEM5_DIR=$(readlink -f gem5-official)

cd bench-lx || exit 1

warmup() {
    isa=$2
    cores=$3
    dirname="warmup-$cores-$isa"

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    # delete old checkpoints
    rm -rf run/boot-$isa-$cores/cpt.*

    if LX_CORES="$cores" LX_ARCH="$isa" ./b warmup &> /dev/null; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init "$2"

for isa in riscv64 x86_64; do
    ./b mklx
    ./b mkapps

    for cores in 2 4 6; do
        jobs_submit warmup "$1" $isa $cores
    done
done

jobs_wait
