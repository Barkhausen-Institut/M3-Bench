#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/config-aladdin.py`
input=`readlink -f input/aladdin.cfg`

cd m3
export M3_BUILD=release

export M3_FS=bench.img
export M3_GEM5_CFG=$cfg
export M3_GEM5_DBG=DtuAccelAladdin,DtuAccelAladdinState,Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2
export M3_CORES=5

# export M3_GEM5_CPU=TimingSimpleCPU

run_bench() {
    jobs_started

    export M3_GEM5_OUT=$1/m3-aladdin-$2-$3-$4-$5-$6
    mkdir -p $M3_GEM5_OUT

    /bin/echo -e "\e[1mStarted m3-aladdin-$2-$3-$4-$5-$6\e[0m"

    if [ "$5" = "file" ]; then
        export ALADDIN_ARGS="-s $3 -f -m $4 $2"
    else
        export ALADDIN_ARGS="-s $3 -m $4 $2"
    fi
    export KERNEL_ARGS="-t=$(($6 * 3000000))"
    export ACCEL_PCIE=0

    ./b run $input -n > $M3_GEM5_OUT/output.txt 2>&1
    [ $? -eq 0 ] || exit 1

    /bin/echo -e "\e[1mFinished m3-aladdin-$2-$3-$4-$5-$6\e[0m"
}

./b || exit 1

jobs_init $2

# for b in stencil md fft spmv; do
for b in fft; do
    for s in 1 4 16 64 256 0; do
        jobs_submit run_bench $1 $b $s 0 file 1
        jobs_submit run_bench $1 $b $s 0 anon 1
    done
done

# for ts in 1 2 4; do
#     for b in stencil md fft spmv; do
#         for m in 1 2; do
#             jobs_submit run_bench $1 $b 0 $m file $ts
#         done
#     done
# done

jobs_wait
