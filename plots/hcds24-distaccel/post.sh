#!/bin/bash

. tools/helper.sh

extract_m3() {
    sed -e 's/\x1b\[0m//g' "$1/m3-distaccel-$2-$3/log.txt" | awk -e '
        /PERF/ {
            if (match($0, /PERF "'"$2"'": ([0-9\.]+)µs \(\+\/\- ([0-9\.]+)(ns|µs)/, m) != 0) {
                if (m[3] == "ns") {
                    stddev = m[2]
                } else {
                    stddev = m[2] * 1000
                }
                printf("'"$2 $3"' %f %f\n", m[1] * 1000, stddev)
            }
        }
    '
}

{
    echo "proto datasize latency sd"
    for loc in cli srv-central srv-dist; do
        for sz in 1 2 4 8 16 32; do
            extract_m3 "$1" "$loc" "$((sz * 1024))"
        done
    done
} > "$1/distaccel.dat"
