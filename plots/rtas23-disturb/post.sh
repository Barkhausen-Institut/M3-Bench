#!/bin/bash

. tools/helper.sh

extract_perf() {
    grep ".*PERF \".*\":" "$1/m3-disturb-$2-$3-$4-$5/output.txt"
}
extract_time() {
    extract_perf "$1" "$2" "$3" "$4" "$5" | awk -e '{ print($5) }'
}
extract_stddev() {
    extract_perf "$1" "$2" "$3" "$4" "$5" | awk -e '{ print($8) }'
}

for tgt in hw gem5; do
    for bw in 0 4K 8K 16K 32K 64K 128K 256K 512K 1024K; do
        if [ "$tgt" = "hw" ] && [ "$bw" != "0" ]; then
            continue;
        fi

        echo "fg bg diff" > "$1/$tgt-$bw-disturb.dat"
        for fgm in compute memory transfers msgs; do
            none=$(extract_time "$1" $tgt $bw $fgm "none")
            for bgm in compute memory transfers msgs; do
                dist=$(extract_time "$1" $tgt $bw $fgm $bgm)
                diff=$(echo "scale=4; ($dist. / $none.) - 1" | bc)
                echo "$fgm $bgm: $none $dist (+/- $(extract_stddev "$1" $tgt $bw $fgm $bgm)) --> $diff"
                echo "$fgm $bgm $diff" >> "$1/$tgt-$bw-disturb.dat"
            done
        done
    done
done
