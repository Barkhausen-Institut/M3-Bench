#!/bin/bash

. tools/helper.sh

extract_m3() {
    sed -e 's/\x1b\[0m//g' "$1/m3-ycsb/log.txt" | awk -e '
        /client: replay=/ {
            replay += 1
            if (replay >= 2) {
                if (match($0, /client: replay=([0-9]+) cycles, op=([0-9]+) cycles, xfer=([0-9]+) cycles/, m) != 0) {
                    if (op == 0) {
                        op = m[2]
                    }
                    printf("M³ Transfers %d\n", m[3])
                    printf("M³ RPCs %d\n", m[1] - (m[2] + m[3]))
                    printf("M³ Compute %d\n", op)
                }
            }
        }
    '
}

extract_shm() {
    awk -e '
        /total: / {
            replay += 1
            if (replay >= 2) {
                if (match($0, /total: ([0-9]+) cycles, xfer: ([0-9]+) cycles, comp: ([0-9]+) cycles/, m) != 0) {
                    printf("MMU+IPIs Transfers %d\n", m[2])
                    printf("MMU+IPIs RPCs %d\n", m[1] - (m[2] + m[3]))
                    printf("MMU+IPIs Compute %d\n", m[3])
                }
            }
        }
    ' "$1/shm-ycsb/log.txt"
}

echo "platform type latency" > "$1/ycsb.dat"
extract_m3 "$1" >> "$1/ycsb.dat"
extract_shm "$1" >> "$1/ycsb.dat"

for i in 1 2 3 4 5 6 7 8; do
    echo "SR-IOV Transfers $((20000 * 1000))" >> "$1/ycsb.dat"
    echo "SR-IOV RPCs $((150000 * 2000))" >> "$1/ycsb.dat"
    echo "SR-IOV Compute 97660377" >> "$1/ycsb.dat"
done
