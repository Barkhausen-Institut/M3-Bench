#!/bin/bash

. tools/jobs.sh

cd m3 || exit 1

export M3_BUILD=release
export M3_TARGET=gem5 M3_ISA=riscv
if [ -z "$M3_GEM5_DBG" ]; then
    export M3_GEM5_DBG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPUFREQ=2GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG=config/caches.py

./b || exit 1

run_bench() {
    limit=$2

    dirname=m3-membw-$limit
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    tmp=$(mktemp)
    (
        echo "<config>"
        echo "  <kernel args=\"kernel\" />"
        echo "  <dom>"
        echo "    <app args=\"root\">"
        for i in {0..7}; do
            echo "      <dom>"
            if [ "$i" -ne 7 ] && [ "$limit" != "0" ]; then
                echo "        <app args=\"memconsumer\" mem-bw=\"$limit\" />"
            else
                echo "        <app args=\"memconsumer\" />"
            fi
            echo "      </dom>"
        done
        echo "    </app>"
        echo "  </dom>"
        echo "</config>"
    ) > "$tmp"
    trap 'rm -f $tmp' SIGINT SIGTERM EXIT

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    ./b run "$tmp" -n < /dev/null &> "$M3_OUT/output.txt"

    if [ $? -eq 0 ]; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

jobs_init "$2"

for bw in 0 16K 32K 64K 128K 256K 512K 1024K; do
    jobs_submit run_bench "$1" $bw
done

jobs_wait
