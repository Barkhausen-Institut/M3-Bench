#!/bin/sh

. tools/helper.sh

extract_m3_time() {
    grep "PERF" $1 | \
        sed -e 's/\x1b\[0m//g' | \
        sed -re 's/.*PERF "\S+.*": ([0-9]*).*/\1/'
}

extract_m3_stddev() {
    grep "PERF" $1 | \
        sed -e 's/\x1b\[0m//g' | \
        sed -re 's/.*PERF "\S+.*": [0-9]*.*- ([0-9.]*).*/\1/'
}

cycles_to_time() {
    # cycles to us
    echo "1000000 / (80000000 / $1)" | bc
}

m3sh=$(cycles_to_time $(extract_m3_time $1/m3-netlat-shared/output.txt))
m3ex=$(cycles_to_time $(extract_m3_time $1/m3-netlat-iso/output.txt))
lx=$(cycles_to_time $(cut -d ' ' -f 1 $1/lx-netlat/res.txt))
echo $m3ex $m3sh $lx > $1/netlat-times.dat

m3sh=$(cycles_to_time $(extract_m3_stddev $1/m3-netlat-shared/output.txt))
m3ex=$(cycles_to_time $(extract_m3_stddev $1/m3-netlat-iso/output.txt))
lx=$(cycles_to_time $(cut -d ' ' -f 2 $1/lx-netlat/res.txt))
echo $m3ex $m3sh $lx > $1/netlat-stddev.dat
