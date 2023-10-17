#!/bin/bash

. tools/helper.sh

extract_m3() {
    if [ "$4" = "sender" ]; then
        grep "PERF" "$1/m3-sendprios-hw-$2-$3-$4/output.txt" | \
            sed -Ee "s/.*PERF \"prio(.*)\": (.*)ms \(\+\/- (.*) with.*/$3-\1 $2 \2 \3/g" | \
            sed -e "s/1-1/No-prios/g" | \
            sed -e "s/2-1/High/g" | \
            sed -e "s/2-2/Low/g"
    else
        grep "PERF" "$1/m3-sendprios-hw-$2-$3-$4/output.txt"
    fi
}

echo "type clients time stddev" > "$1/sendprios.dat"
echo "type clients time stddev" > "$1/sendprios-bomber.dat"
for c in {1..6}; do
    extract_m3 "$1" "$c" 1 "sender" >> "$1/sendprios.dat"
    extract_m3 "$1" "$c" 2 "sender" >> "$1/sendprios.dat"
    extract_m3 "$1" "$c" 2 "bomber" >> "$1/sendprios-bomber.dat"
done
