#!/bin/sh

cfg=`readlink -f input/rctmux-pipe.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

run_pipe() {
    /bin/echo -e "\e[1mRunning $2-alone...\e[0m"
    M3_CORES=7 M3_RCTMUX_ARGS="0 $3" ./b run $cfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-$2-alone.txt
    cp $M3_LOG $1/m3-rctmux-$2-alone.log

    /bin/echo -e "\e[1mRunning $2-shared...\e[0m"
    M3_CORES=6 M3_RCTMUX_ARGS="1 $3" ./b run $cfg
    ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-$2-shared.txt
    cp $M3_LOG $1/m3-rctmux-$2-shared.log
}

run_pipe $1 rand-wc     "2 /bin/rand 250000 /bin/wc"
run_pipe $1 cat-wc      "2 /bin/cat /medium.txt /bin/wc"
run_pipe $1 cat-sink    "2 /bin/cat /medium.txt /bin/sink"
run_pipe $1 rand-sink   "2 /bin/rand 250000 /bin/sink"
