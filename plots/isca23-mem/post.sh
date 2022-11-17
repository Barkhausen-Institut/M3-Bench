#!/bin/bash

. tools/helper.sh

extract_m3() {
    sed -e 's/\x1b\[0m//g' "$1/m3-mem-$2/log.txt" | awk -e '
        /PERF/ {
            if (match($0, /PERF "write ([0-9]+)b with [0-9]+b buf": ([0-9]+) cycles/, m) != 0) {
                printf("M³-'"$2"' %db %d\n", m[1], m[2])
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
    ' "$1/shm-mem/log.txt"
}

extract_sriov() {
    tail -n +2 "$1/sriov-mem/results.csv" | while read line; do
        for i in {1..8}; do
            time=$(echo "$line" | cut -d ',' -f "$i")
            if [ $time -ne 0 ]; then
                echo "SR-IOV+IOMMUs $((1 << ((i - 1) * 4)))b $time"
            fi
        done
    done
}

echo "platform datasize latency" > "$1/mem.dat"
extract_m3 "$1" "memcpy" >> "$1/mem.dat"
extract_m3 "$1" "tcu" >> "$1/mem.dat"
extract_shm "$1" >> "$1/mem.dat"
extract_sriov "$1" >> "$1/mem.dat"
