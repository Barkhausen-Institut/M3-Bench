#!/bin/bash

. tools/helper.sh

extract_bw() {
    grep "$2.*PRINT:.*Transferred" "$1/m3-membw-$3/gem5.log" | awk -e '{ printf("%.0f\n", $9) }'
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

extract_bg_stddev() {
    avg=$(extract_bg "$1" "$2")
    sum=0
    for t in T02 T03 T04 T05 T06 T07 T08; do
        bw=$(extract_bw "$1" $t "$2")
        val=$((bw - avg))
        sum=$((sum + (val * val)))
    done
    echo "sqrt($sum / 7)" | bc
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
    bgsd=$(extract_bg_stddev "$1" $bw_name)
    sdper=$(echo "scale=4; 100*($bgsd/$bg)" | bc)
    if [ "$bw" != "-" ]; then
        diff=$(echo "scale=4; 100 * ($bg / ($bw * 1000000))" | bc)
    else
        diff=0
    fi

    echo "FG $bw $fg" >> "$1/membw.dat"
    echo "BG $bw $bg" >> "$1/membw.dat"
    echo $bw $((fg / 1000000)) $((bg / 1000000)) "$sdper%" "$diff"
done
