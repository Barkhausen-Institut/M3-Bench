#!/bin/sh

benchcfg=`readlink -f input/rctmux.cfg`
pipecfg=`readlink -f input/rctmux-pipe.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing
# export M3_GEM5_CC=1

run_pipe() {
    /bin/echo -e "\e[1mRunning pipe-alone...\e[0m"
    M3_CORES=7 M3_RCTMUX_ARGS="0 /large.txt" ./b run $pipecfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-pipe-alone.txt
    cp $M3_LOG $1/m3-rctmux-pipe-alone.log

    /bin/echo -e "\e[1mRunning pipe-shared...\e[0m"
    M3_CORES=7 M3_RCTMUX_ARGS="1 /large.txt" ./b run $pipecfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-pipe-shared.txt
    cp $M3_LOG $1/m3-rctmux-pipe-shared.log
}

run_fstrace() {
    /bin/echo -e "\e[1mRunning $2-alone...\e[0m"
    cp $1/lx-fstrace-$2-30cycles.txt-opcodes.c src/apps/fstrace/m3fs/trace.c
    M3_CORES=6 M3_RCTMUX_ARGS="0 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" ./b run $benchcfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-$2-alone.txt
    cp $M3_LOG $1/m3-rctmux-$2-alone.log

    /bin/echo -e "\e[1mRunning $2-shared...\e[0m"
    M3_CORES=5 M3_RCTMUX_ARGS="1 2 /bin/fstrace-m3fs /tmp/1/ /bin/fstrace-m3fs /tmp/2/" ./b run $benchcfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-$2-shared.txt
    cp $M3_LOG $1/m3-rctmux-$2-shared.log
}

# run_pipe $1
run_fstrace $1 tar
run_fstrace $1 untar
run_fstrace $1 find
run_fstrace $1 sqlite
