#!/bin/bash

dirname=shm-facever
export OUT=$1/$dirname
mkdir -p "$OUT"

echo -n "Enter sudo password on Altra machine: "
read -r -s pwd
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

# the FractOS CPU supposedly didn't run in Turbomode due to too much load and therefore at 2.1GHz
wl256=$(echo "256 * 2100" | bc)
wl512=$(echo "512 * 2100" | bc)
wl1024=$(echo "1024 * 2100" | bc)

# from the FractOS benchmark scripts: assume 0.3 for storage time, 1.3 for GPU time
run "$1" \
    $((256 * 1024)) \
    "$(printf "%.0f" "$(echo "$wl256 * 1.3" | bc)")" \
    "$(printf "%.0f" "$(echo "$wl256 * 0.3" | bc)")" \
    10000

run "$1" \
    $((512 * 1024)) \
    "$(printf "%.0f" "$(echo "$wl512 * 1.3" | bc)")" \
    "$(printf "%.0f" "$(echo "$wl512 * 0.3" | bc)")" \
    10000

run "$1" \
    $((1024 * 1024)) \
    "$(printf "%.0f" "$(echo "$wl1024 * 1.3" | bc)")" \
    "$(printf "%.0f" "$(echo "$wl1024 * 0.3" | bc)")" \
    10000

