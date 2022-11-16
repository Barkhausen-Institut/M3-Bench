#!/bin/bash

dirname=shm-ycsb
export OUT=$1/$dirname
mkdir -p "$OUT"

echo -n "Enter sudo password on Altra machine: "
read -s pwd
echo

/bin/echo -e "\e[1mStarting $dirname\e[0m"

scp input/ycsb-read.log altra:isca-shm
ssh altra "source .profile && cd isca-shm; " \
    "echo -n $pwd | sudo -S cpupower frequency-set -g performance &>/dev/null; " \
    "cargo r --release --bin ycsb -- -w 1 -r 10 -f 2800 ycsb-read.log ;" \
    "echo -n $pwd | sudo -S cpupower frequency-set -g schedutil &>/dev/null" &> "$OUT/log.txt"

/bin/echo -e "\e[1mFinished $dirname\e[0m"
