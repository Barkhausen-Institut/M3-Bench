#!/bin/bash

. tools/helper.sh

extract_m3() {
    sed -e 's/\x1b\[0m//g' "$1/m3-ipc/log.txt" | awk -e '
        /PERF/ {
            if (match($0, /PERF "pingpong with ([0-9]+)b msgs": ([0-9]+) cycles/, m) != 0) {
                printf("M³ %db %d\n", m[1], m[2])
            }
        }
    '
}

extract_shm() {
    awk -e '
        /[0-9]+b: / {
            if (match($0, /([0-9]+)b: ([0-9]+) cycles per run/, m) != 0) {
                printf("MMU+IPIs %db %d\n", m[1], m[2])
            }
        }
    ' "$1/shm-ipc/log.txt"
}

echo "platform msgsize latency" > "$1/ipc.dat"
extract_m3 "$1" >> "$1/ipc.dat"
extract_shm "$1" >> "$1/ipc.dat"

for s in 1 2 4 8 16 32 64 128 256 512 1024 2032; do
    latency=$((150000 + s * 10))
    echo "SR-IOV ${s}b $latency" >> "$1/ipc.dat"
done
