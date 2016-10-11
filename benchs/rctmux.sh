#!/bin/sh

cfg=`readlink -f input/rctmux.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

run_fstrace_alone() {
    /bin/echo -e "\e[1mRunning $2-alone...\e[0m"
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c src/apps/fstrace/m3fs/trace.c
    M3_CORES=6 M3_RCTMUX_ARGS="0 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" ./b run $cfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-$2-alone.txt
    mv $M3_LOG $1/m3-rctmux-$2-alone.log
}

run_fstrace_shared() {
    /bin/echo -e "\e[1mRunning $2-shared...\e[0m"
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c src/apps/fstrace/m3fs/trace.c
    M3_CORES=5 M3_RCTMUX_ARGS="1 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" ./b run $cfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-$2-shared.txt
    mv $M3_LOG $1/m3-rctmux-$2-shared.log
}

run_fstrace_alone $1 tar
run_fstrace_shared $1 tar
run_fstrace_alone $1 untar
run_fstrace_shared $1 untar
run_fstrace_alone $1 find
run_fstrace_shared $1 find
run_fstrace_alone $1 sqlite
run_fstrace_shared $1 sqlite
