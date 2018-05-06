#!/bin/bash

. tools/jobs.sh

cfg=`readlink -f input/rctmux-pipe.cfg`

cd m3
export M3_BUILD=release M3_FS=bench.img

export M3_GEM5_DBG=Dtu,DtuRegWrite,DtuCmd,DtuConnector
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz

# export M3_GEM5_CPU=TimingSimpleCPU

run() {
    jobs_started

    /bin/echo -e "\e[1mStarting m3-pipe-ctx-$3-$4-$5-$6\e[0m"

    export M3_GEM5_OUT=$1/m3-pipe-ctx-$3-$4-$5-$6
    mkdir -p $M3_GEM5_OUT

    export M3_RCTMUX_ARGS="$2"

    export M3_GEM5_CFG=config/caches.py
    export M3_GEM5_MMU=1 M3_GEM5_DTUPOS=2

    ./b run $cfg -n 1>$M3_GEM5_OUT/output.txt 2>&1

    if [ "`grep "Time: " $M3_GEM5_OUT/output.txt | wc -l`" = "4" ]; then
        /bin/echo -e "\e[1mFinished m3-pipe-ctx-$3-$4-$5-$6:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished m3-pipe-ctx-$3-$4-$5-$6:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init $2

./b

export M3_CORES=6
for sz in 512 1024 2048 4096; do
    jobs_submit run $1 "1 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/wc" shared rand wc $sz
    jobs_submit run $1 "1 0 4 2 1 /bin/cat /data/${sz}k.txt /bin/wc" shared cat wc $sz
    jobs_submit run $1 "1 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/sink" shared rand sink $sz
    jobs_submit run $1 "1 0 4 2 1 /bin/cat /data/${sz}k.txt /bin/sink" shared cat sink $sz
done

export M3_CORES=7
for sz in 512 1024 2048 4096; do
    jobs_submit run $1 "0 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/wc" alone rand wc $sz
    jobs_submit run $1 "0 0 4 2 1 /bin/cat /data/${sz}k.txt /bin/wc" alone cat wc $sz
    jobs_submit run $1 "0 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/sink" alone rand sink $sz
    jobs_submit run $1 "0 0 4 2 1 /bin/cat /data/${sz}k.txt /bin/sink" alone cat sink $sz
done

export M3_CORES=7
for sz in 512 1024 2048 4096; do
    jobs_submit run $1 "3 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/wc" shared-m3fs rand wc $sz
    jobs_submit run $1 "3 0 4 2 1 /bin/cat /foo/data/${sz}k.txt /bin/wc" shared-m3fs cat wc $sz
    jobs_submit run $1 "3 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/sink" shared-m3fs rand sink $sz
    jobs_submit run $1 "3 0 4 2 1 /bin/cat /foo/data/${sz}k.txt /bin/sink" shared-m3fs cat sink $sz
done

export M3_CORES=6
for sz in 512 1024 2048 4096; do
    jobs_submit run $1 "4 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/wc" shared-all rand wc $sz
    jobs_submit run $1 "4 0 4 2 1 /bin/cat /foo/data/${sz}k.txt /bin/wc" shared-all cat wc $sz
    jobs_submit run $1 "4 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/sink" shared-all rand sink $sz
    jobs_submit run $1 "4 0 4 2 1 /bin/cat /foo/data/${sz}k.txt /bin/sink" shared-all cat sink $sz
done

export M3_CORES=5
for sz in 512 1024 2048 4096; do
    jobs_submit run $1 "4 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/wc" shared-1pe rand wc $sz
    jobs_submit run $1 "4 0 4 2 1 /bin/cat /data/${sz}k.txt /bin/wc" shared-1pe cat wc $sz
    jobs_submit run $1 "4 0 4 2 1 /bin/rand $(($sz * 1024)) /bin/sink" shared-1pe rand sink $sz
    jobs_submit run $1 "4 0 4 2 1 /bin/cat /data/${sz}k.txt /bin/sink" shared-1pe cat sink $sz
done

jobs_wait
