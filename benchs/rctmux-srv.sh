#!/bin/sh

cfg=`readlink -f input/rctmux-srv.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

/bin/echo -e "\e[1mRunning srv-direct...\e[0m"
M3_CORES=6 M3_RCTMUX_ARGS="0" ./b run $cfg
./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-srv-direct.txt
cp $M3_LOG $1/m3-rctmux-srv-direct.log

/bin/echo -e "\e[1mRunning srv-indirect...\e[0m"
M3_CORES=5 M3_RCTMUX_ARGS="1" ./b run $cfg
./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-srv-indirect.txt
cp $M3_LOG $1/m3-rctmux-srv-indirect.log
