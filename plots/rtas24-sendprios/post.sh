#!/bin/bash

. tools/helper.sh

extract_m3() {
    grep "PERF" "$1/m3-sendprios-hw-$2-$3/output.txt" | \
        sed -Ee "s/.*PERF \"prio(.*)\": (.*)ms \(\+\/- (.*) with.*/$3-\1 $2 \2 \3/g" | \
        sed -e "s/1-1/No-prios/g" | \
        sed -e "s/2-1/High/g" | \
        sed -e "s/2-2/Low/g"
}

echo "type clients time stddev" > "$1/sendprios.dat"
for c in {1..6}; do
    extract_m3 "$1" "$c" 1 >> "$1/sendprios.dat"
    extract_m3 "$1" "$c" 2 >> "$1/sendprios.dat"
done
