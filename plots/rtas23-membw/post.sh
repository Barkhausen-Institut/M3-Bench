#!/bin/sh

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

for bw in 16K 32K 64K 128K 256K 512K 1024K 0; do
    fg=$(extract_fg "$1" $bw)
    bg=$(extract_bg "$1" $bw)

    echo "FG BG" > "$1/membw-$bw.dat"
    echo "$fg" "$bg" >> "$1/membw-$bw.dat"
    echo $bw $((fg / 1000000)) $((bg / 1000000))
done
