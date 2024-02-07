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
    for bw in 0 8K 32K 128K 512K 2048K; do
        if [ "$tgt" = "hw" ] && [ "$bw" != "0" ]; then
            continue;
        fi

        echo "fg bg diff" > "$1/$tgt-$bw-disturb.dat"
        echo "fg bg baseline disturbed diff stddev" > "$1/$tgt-$bw-disturb-detail.dat"
        for fgm in compute memory transfers msgs; do
            none=$(extract_time "$1" $tgt $bw $fgm "none")
            for bgm in compute memory transfers msgs; do
                dist=$(extract_time "$1" $tgt $bw $fgm $bgm)
                diff=$(echo "scale=4; ($dist. / $none.) - 1" | bc)
                stddev=$(extract_stddev "$1" $tgt $bw $fgm $bgm)
                relstddev=$(echo "scale=4; $stddev. / $none." | bc)
                echo "$fgm $bgm $none $dist $diff $stddev" >> "$1/$tgt-$bw-disturb-detail.dat"
                echo "$fgm $bgm $diff" >> "$1/$tgt-$bw-disturb.dat"
                echo $fgm $bgm "$relstddev"
            done
        done
    done
done
