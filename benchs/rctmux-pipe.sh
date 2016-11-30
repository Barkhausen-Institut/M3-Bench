#!/bin/sh

cfg=`readlink -f input/rctmux-pipe.cfg`

cd m3
export M3_BUILD=bench M3_FS=bench.img

export M3_GEM5_CFG=config/caches.py
export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuSysCalls,DtuCmd,DtuConnector
# export M3_GEM5_CPU=timing

run() {
    /bin/echo -e "\e[1mRunning $2-$3...\e[0m"

    ./b run $cfg

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1;32mSUCCESS\e[0m"
        ./src/tools/bench.sh $M3_LOG > $1/m3-rctmux-$2-$3.txt
        mv $M3_LOG $1/m3-rctmux-$2-$3.log
    else
        /bin/echo -e "\e[1;31mFAILED\e[0m"
    fi
}

run_pipe() {
    M3_CORES=7 M3_RCTMUX_ARGS="0 $3" run $1 $2 alone
    M3_CORES=6 M3_RCTMUX_ARGS="1 $3" run $1 $2 shared
}

run_pipe_m3fs() {
    M3_CORES=8 M3_RCTMUX_ARGS="2 $3" run $1 $2 m3fs-alone
    M3_CORES=7 M3_RCTMUX_ARGS="3 $3" run $1 $2 m3fs-shared
}

run_pipe $1 rand-wc-64k      "2 /bin/rand $((64*1024)) /bin/wc"
run_pipe $1 rand-wc-128k     "2 /bin/rand $((128*1024)) /bin/wc"
run_pipe $1 rand-wc-256k     "2 /bin/rand $((256*1024)) /bin/wc"
run_pipe $1 rand-wc-512k     "2 /bin/rand $((512*1024)) /bin/wc"
run_pipe $1 rand-wc-1024k    "2 /bin/rand $((1024*1024)) /bin/wc"

run_pipe $1 cat-wc-64k       "2 /bin/cat /data/64k.txt /bin/wc"
run_pipe $1 cat-wc-128k      "2 /bin/cat /data/128k.txt /bin/wc"
run_pipe $1 cat-wc-256k      "2 /bin/cat /data/256k.txt /bin/wc"
run_pipe $1 cat-wc-512k      "2 /bin/cat /data/512k.txt /bin/wc"
run_pipe $1 cat-wc-1024k     "2 /bin/cat /data/1024k.txt /bin/wc"

run_pipe $1 rand-sink-64k    "2 /bin/rand $((64*1024)) /bin/sink"
run_pipe $1 rand-sink-128k   "2 /bin/rand $((128*1024)) /bin/sink"
run_pipe $1 rand-sink-256k   "2 /bin/rand $((256*1024)) /bin/sink"
run_pipe $1 rand-sink-512k   "2 /bin/rand $((512*1024)) /bin/sink"
run_pipe $1 rand-sink-1024k  "2 /bin/rand $((1024*1024)) /bin/sink"

run_pipe $1 cat-sink-64k       "2 /bin/cat /data/64k.txt /bin/sink"
run_pipe $1 cat-sink-128k      "2 /bin/cat /data/128k.txt /bin/sink"
run_pipe $1 cat-sink-256k      "2 /bin/cat /data/256k.txt /bin/sink"
run_pipe $1 cat-sink-512k      "2 /bin/cat /data/512k.txt /bin/sink"
run_pipe $1 cat-sink-1024k     "2 /bin/cat /data/1024k.txt /bin/sink"

run_pipe_m3fs $1 cat-wc-64k  "5 /bin/cat /foo/data/16k.txt /foo/data/16k.txt /foo/data/16k.txt /foo/data/16k.txt /bin/wc"
run_pipe_m3fs $1 cat-wc-128k "5 /bin/cat /foo/data/32k.txt /foo/data/32k.txt /foo/data/32k.txt /foo/data/32k.txt /bin/wc"
run_pipe_m3fs $1 cat-wc-256k "5 /bin/cat /foo/data/64k.txt /foo/data/64k.txt /foo/data/64k.txt /foo/data/64k.txt /bin/wc"
run_pipe_m3fs $1 cat-wc-512k "5 /bin/cat /foo/data/128k.txt /foo/data/128k.txt /foo/data/128k.txt /foo/data/128k.txt /bin/wc"
run_pipe_m3fs $1 cat-wc-1024k "5 /bin/cat /foo/data/256k.txt /foo/data/256k.txt /foo/data/256k.txt /foo/data/256k.txt /bin/wc"
