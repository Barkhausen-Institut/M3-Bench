#!/bin/bash

. tools/helper.sh

extract_perf() {
    grep ".*PERF \".*\":" "$1/m3-disturb-$2-$3/output.txt"
}
extract_time() {
    extract_perf "$1" "$2" "$3" | awk -e '{ print($5) }'
}
extract_stddev() {
    extract_perf "$1" "$2" "$3" | awk -e '{ print($8) }'
}

echo "fg bg diff" > "$1/disturb.dat"

for fgm in compute memory transfers msgs; do
    none=$(extract_time "$1" $fgm "none")
    for bgm in compute memory transfers msgs; do
        dist=$(extract_time "$1" $fgm $bgm)
        diff=$(echo "scale=4; ($dist. / $none.)" | bc)
        echo "$fgm $bgm: $none $dist (+/- $(extract_stddev "$1" $fgm $bgm)) --> $diff"
        echo "$fgm $bgm $diff" >> "$1/disturb.dat"
    done
done
