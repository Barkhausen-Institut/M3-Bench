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
                    printf("IPIs+MMU Transfers %d\n", m[2])
                    printf("IPIs+MMU RPCs %d\n", m[1] - (m[2] + m[3]))
                    printf("IPIs+MMU Compute %d\n", m[3])
                }
            }
        }
    ' "$1/shm-ycsb/log.txt"
}

extract_sriov() {
    declare -A comps
    c=0
    while read line; do
        comps[$c]=$line
        c=$((c + 1))
    done < <(grep "compute:" "input/ycsb-read.log" | sed -e 's/compute: //g')

    c=0
    xfers=0
    rpcs=0
    comp=0
    OLDIFS=$IFS
    IFS=","
    tail -n +2 "$1/sriov-ycsb/results.csv" | while read total rdma; do
        if [ $c -eq ${#comps[@]} ]; then
            echo "SR-IOV+IOMMUs Transfers $xfers"
            echo "SR-IOV+IOMMUs RPCs $rpcs"
            echo "SR-IOV+IOMMUs Compute $comp"
            xfers=0
            rpcs=0
            comp=0
            c=0
        fi

        comp=$((comp + comps[$c]))
        rpc=$((total - (comps[$c] + rdma)))
        rpcs=$((rpcs + rpc))
        xfers=$((xfers + rdma))

        c=$((c + 1))
    done
    IFS=$OLDIFS
}

echo "platform type latency" > "$1/ycsb.dat"
extract_m3 "$1" >> "$1/ycsb.dat"
extract_shm "$1" >> "$1/ycsb.dat"
extract_sriov "$1" >> "$1/ycsb.dat"
