#!/bin/bash

. tools/helper.sh

m3bpe=64
mhz=`get_mhz $1/m3-fs-read-a-$m3bpe/output.txt`

sum() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "PE$3-TIME: $2" | awk '
        { sum += $4 } END { printf("TIME: 0000 : %u\n", sum) }
    '
}
total() {
    ./tools/m3-bench.sh time $2 $mhz 1 $3 < $1
}
m3_total() {
    total $1/times.log 0001
}
stddev() {
    ./tools/m3-bench.sh stddev $2 $mhz 1 $3 < $1
}
xfer() {
    for f in $1/gem5-*; do
        sum $f aaaa $2
    done
}
m3_xfer() {
    # count transfers on m3fs and benchmark PE
    m3fs=$(xfer $1 1 | ./tools/m3-avg.awk)
    app=$(xfer $1 2 | ./tools/m3-avg.awk)
    echo $(($m3fs + $app))
}

gen_data() {
    m3toa=`m3_total $1/m3-fs-$2-a-$m3bpe`
    m3xfa=`m3_xfer $1/m3-fs-$2-a-$m3bpe`
    m3tob=`m3_total $1/m3-fs-$2-b-$m3bpe`
    m3xfb=`m3_xfer $1/m3-fs-$2-b-$m3bpe`
    m3toc=`m3_total $1/m3-fs-$2-c-$m3bpe`
    m3xfc=`m3_xfer $1/m3-fs-$2-c-$m3bpe`

    echo "M3-a M3-b M3-c"
    echo "$m3xfa $m3xfb $m3xfc"
    echo "$(($m3toa - $m3xfa)) $(($m3tob - $m3xfb)) $(($m3toc - $m3xfc))"
}

gen_var() {
    m3toa=`stddev $1/m3-fs-$2-a-$m3bpe/times.log 0001`
    m3tob=`stddev $1/m3-fs-$2-b-$m3bpe/times.log 0001`
    m3toc=`stddev $1/m3-fs-$2-c-$m3bpe/times.log 0001`

    echo "$m3toa $m3tob $m3toc"
}

for pe in a b c; do
    for b in read write copy; do
        echo "Splitting M3-$b-$pe results..."
        grep "DEBUG 0x" $1/m3-fs-$b-$pe-$m3bpe/gem5.log > $1/m3-fs-$b-$pe-$m3bpe/times.log
        csplit -s --prefix="$1/m3-fs-$b-$pe-$m3bpe/gem5-" $1/m3-fs-$b-$pe-$m3bpe/times.log "/DEBUG 0x1ff20001/+1" "{*}"
        rm $1/m3-fs-$b-$pe-$m3bpe/gem5-{00,05}
    done
done

echo "Generating data files..."
gen_data $1 read > $1/fs-read.dat
gen_data $1 write > $1/fs-write.dat
gen_data $1 copy > $1/fs-copy.dat

echo "Generating stddev files..."
gen_var $1 read > $1/fs-read-stddev.dat
gen_var $1 write > $1/fs-write-stddev.dat
gen_var $1 copy > $1/fs-copy-stddev.dat

Rscript plots/diss-vm-fs/plot.R $1/eval-fs.pdf \
    $1/fs-read.dat $1/fs-read-stddev.dat \
    $1/fs-write.dat $1/fs-write-stddev.dat \
    $1/fs-copy.dat $1/fs-copy-stddev.dat
