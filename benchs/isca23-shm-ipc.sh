#!/bin/bash

dirname=shm-ipc
export OUT=$1/$dirname
mkdir -p "$OUT"

echo -n "Enter sudo password on Altra machine: "
read -r -s pwd
echo

/bin/echo -e "\e[1mStarting $dirname\e[0m"

ssh altra "source .profile && cd isca-shm; " \
    "echo -n $pwd | sudo -S cpupower frequency-set -g performance &>/dev/null; " \
    "for s in 1 2 4 8 16 32 64 128 256 512 1024 2032; do " \
    "  cargo r --release --bin msgs -- -m \$s -w 10 -r 1000000 -f 2800; " \
    "done; " \
    "echo -n $pwd | sudo -S cpupower frequency-set -g schedutil &>/dev/null" &> "$OUT/log.txt"

/bin/echo -e "\e[1mFinished $dirname\e[0m"
