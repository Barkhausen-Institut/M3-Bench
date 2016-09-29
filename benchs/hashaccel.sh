#!/bin/sh

directcfg=`readlink -f input/hash.cfg`
indirectcfg=`readlink -f input/hashserv.cfg`

cd m3
export M3_BUILD=bench

export M3_GEM5_CFG=config/default.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuAccel,DtuAccelState,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

/bin/echo -e "\e[1mRunning direct access benchmark...\e[0m"
M3_CORES=8 ./b run $directcfg
cp $M3_LOG $1/m3-hash-direct.log

/bin/echo -e "\e[1mRunning indirect access benchmark...\e[0m"
M3_CORES=8 ./b run $indirectcfg
cp $M3_LOG $1/m3-hash-indirect.log
