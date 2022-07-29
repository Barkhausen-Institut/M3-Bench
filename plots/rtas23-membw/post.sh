#!/bin/bash

. tools/helper.sh

extract_bw() {
    grep "$2.*PRINT:.*Transferred" "$1/m3-membw-$3/gem5.log" | awk -e '{ print($9) }'
}

extract_fg() {
    extract_bw "$1" T09 "$2"
}

extract_bg() {
    total=0
    for t in T02 T03 T04 T05 T06 T07 T08; do
        total=$((total + $(extract_bw "$1" $t "$2")))
    done
    echo $((total / 7))
}

echo "load limit throughput" > "$1/membw.dat"
for bw in 16 32 64 128 256 512 1024 -; do
    if [ $bw = "-" ]; then
        bw_name="0"
    else
        bw_name="${bw}K"
    fi
    fg=$(extract_fg "$1" $bw_name)
    bg=$(extract_bg "$1" $bw_name)

    echo "FG $bw $fg" >> "$1/membw.dat"
    echo "BG $bw $bg" >> "$1/membw.dat"
    echo $bw $((fg / 1000000)) $((bg / 1000000))
done
