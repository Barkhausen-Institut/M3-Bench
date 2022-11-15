#!/bin/bash

dirname=shm-mem
export OUT=$1/$dirname
mkdir -p "$OUT"

echo -n "Enter sudo password on Altra machine: "
read -s pwd
echo

/bin/echo -e "\e[1mStarting $dirname\e[0m"

ssh altra "source .profile && cd isca-shm; " \
    "echo -n $pwd | sudo -S cpupower frequency-set -g performance &>/dev/null; " \
    "i=0; " \
    "while [ \$i -le 28 ]; do " \
    "  cargo r --release --bin mem -- -d \$((1 << i)) -w 10 -r 1000 -f 2800; " \
    "  i=\$((i + 4)); " \
    "done; " \
    "echo -n $pwd | sudo -S cpupower frequency-set -g schedutil &>/dev/null" &> "$OUT/log.txt"

/bin/echo -e "\e[1mFinished $dirname\e[0m"
