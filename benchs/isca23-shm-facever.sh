#!/bin/bash

dirname=shm-facever
export OUT=$1/$dirname
mkdir -p "$OUT"

echo -n "Enter sudo password on Altra machine: "
read -s pwd
echo

run() {
    size="$1"
    gpu="$2"
    storage="$3"
    fs="$4"

    /bin/echo -e "\e[1mStarting $dirname-$size\e[0m"

    ssh altra "source .profile && cd isca-shm; " \
        "echo -n $pwd | sudo -S cpupower frequency-set -g performance &>/dev/null; " \
        "cargo r --release --bin facever -- -w 100 -r 1000 -f 2800 -m 256 -d $size " \
            " --fs-compute $fs --gpu-compute $gpu --storage-compute $storage;" \
        "echo -n $pwd | sudo -S cpupower frequency-set -g schedutil &>/dev/null" &> "$OUT/log-$size.txt"

    /bin/echo -e "\e[1mFinished $dirname-$size\e[0m"
}

run 0 0 0 0
run $((256 * 1024)) $((3 * 350 * 1000)) $((3 * 50 * 1000)) 10000
run $((512 * 1024)) $((3 * 700 * 1000)) $((3 * 100 * 1000)) 10000
run $((1024 * 1024)) $((3 * 1400 * 1000)) $((3 * 200 * 1000)) 10000
