#!/bin/zsh

mhz=3000

get_lx_total() {
    tail -n +2 $1/eval-app-pipe-$2-$3.dat | awk '{ sum += $1 } END { print(sum) }'
}
get_m3_total() {
    if [ -f $1/m3-fstrace-pipe-$2-$3-$4/gem5-00 ]; then
        rm -f $1/m3-fstrace-pipe-$2-$3-$4/gem5-*
    fi
    csplit -s --prefix="$1/m3-fstrace-pipe-$2-$3-$4/gem5-" $1/m3-fstrace-pipe-$2-$3-$4/gem5.log /0x1ff21235/+1 "{*}"
    rm $1/m3-fstrace-pipe-$2-$3-$4/gem5-04

    for f in $1/m3-fstrace-pipe-$2-$3-$4/gem5-*; do
        start=`grep --text "DEBUG.*1ff10000" $f | head -n 1 | sed -e 's/\([[:digit:]]*\):.*/\1/'`
        end=`grep --text "DEBUG.*1ff20000" $f | tail -n 1 | sed -e 's/\([[:digit:]]*\):.*/\1/'`
        printf "TIME: 0000 : %u\n" $((($end - $start) * ($mhz / 1000000.)))
    done | tail -n 3 | ./tools/m3-avg.awk
}

echo "m3-3" "m3-2" "m3-1" "lx" > $1/eval-app-pipe-ctx.dat
for wr in cat grep; do
    for rd in awk wc; do
        echo "Calculating time for $wr-$rd..."
        m33=`get_m3_total $1 $wr $rd 0`
        m32=`get_m3_total $1 $wr $rd 1`
        m31=`get_m3_total $1 $wr $rd 2`
        lx=`get_lx_total $1 $wr $rd`
        echo 1 $(((1. * $m31) / $m33)) $(((1. * $m32) / $m33)) $(((1. * $lx) / $m33)) >> $1/eval-app-pipe-ctx.dat
    done
done
