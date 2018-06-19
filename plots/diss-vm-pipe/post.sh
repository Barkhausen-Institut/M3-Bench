#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-pipe-a-dram/output.txt`

m3_idle() {
    for f in $1/gem5-*; do
        grep "pe0$2" $f | awk -v mhz=$mhz '
            /Suspending CU/ {
                match($1, /^([[:digit:]]+):/, m)
                sus=m[1]
            }

            /Waking up CU/ {
                match($1, /^([[:digit:]]+):/, m)
                if (sus != 0)
                    idle += m[1] - sus
            }

            function ticksToCycles(ticks) {
                return ticks * (mhz / 1000000)
            }

            END {
                printf("TIME: 0000 : %u\n", ticksToCycles(idle))
            }
        '
    done
}

sum() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "PE$3-TIME: $2" | awk '
        { sum += $4 } END { printf("TIME: 0000 : %u\n", sum) }
    '
}
total() {
    ./tools/m3-bench.sh time $2 $mhz 0 $3 < $1
}
stddev() {
    ./tools/m3-bench.sh stddev $2 $mhz 0 $3 < $1
}
xfer() {
    for f in $1/gem5-*; do
        sum $f aaaa $2
    done
}
os() {
    for f in $1/gem5-*; do
        sum $f bbbb $2
    done
}

gen_data_total() {
    dira=$1/m3-pipe-a-dram
    dirb=$1/m3-pipe-b-dram
    dirc=$1/m3-pipe-c-dram

    toa=`total $dira/times.log 1234`
    tob=`total $dirb/times.log 1234`
    toc=`total $dirc/times.log 1234`

    echo "M3-a M3-b M3-c"
    echo "$toa $tob $toc"
}

gen_data_rw() {
    dira=$1/m3-pipe-a-dram
    dirb=$1/m3-pipe-b-dram
    dirc=$1/m3-pipe-c-dram

    toa=`total $dira/times.log 1235 $2`
    xfa=`xfer $dira $2 | ./tools/m3-avg.awk`
    ida=`m3_idle $dira $2 | ./tools/m3-avg.awk`

    tob=`total $dirb/times.log 1235 $2`
    xfb=`xfer $dirb $2 | ./tools/m3-avg.awk`
    idb=`m3_idle $dirb $2 | ./tools/m3-avg.awk`

    toc=`total $dirc/times.log 1235 $2`
    xfc=`xfer $dirc $2 | ./tools/m3-avg.awk`
    idc=`m3_idle $dirc $2 | ./tools/m3-avg.awk`

    echo "M3-a M3-b M3-c"
    echo "$xfa $xfb $xfc"
    echo "$(($toa - $xfa - $ida)) $(($tob - $xfb - $idb)) $(($toc - $xfc - $idc))"
    echo "$ida $idb $idc"
}

gen_var() {
    loga=$1/m3-pipe-a-dram/times.log
    logb=$1/m3-pipe-b-dram/times.log
    logc=$1/m3-pipe-c-dram/times.log

    rdtoa=`stddev $loga 1235 6`
    rdtob=`stddev $logb 1235 6`
    rdtoc=`stddev $logc 1235 6`

    wrtoa=`stddev $loga 1235 5`
    wrtob=`stddev $logb 1235 5`
    wrtoc=`stddev $logc 1235 5`

    toa=`stddev $loga 1234`
    tob=`stddev $logb 1234`
    toc=`stddev $logc 1234`

    echo "$toa $tob $toc" > $1/pipe-total-stddev.dat
    echo "$rdtoa $rdtob $rdtoc" > $1/pipe-read-stddev.dat
    echo "$wrtoa $wrtob $wrtoc" > $1/pipe-write-stddev.dat
}

rm $1/m3-pipe-*/gem5-*

for c in a-dram b-dram c-dram; do
    echo "Splitting M3-$c results..."
    grep "\(Suspending\|Waking\|DEBUG 0x\)" $1/m3-pipe-$c/gem5.log > $1/m3-pipe-$c/times.log
    csplit -s --prefix="$1/m3-pipe-$c/gem5-" $1/m3-pipe-$c/times.log "/DEBUG 0x1ff21234/+1" "{*}"
    rm $1/m3-pipe-$c/gem5-00
    rm $1/m3-pipe-$c/gem5-08
done

echo "Generating $1/pipe-total.dat..."
gen_data_total $1 > $1/pipe-total.dat
echo "Generating $1/pipe-read.dat..."
gen_data_rw $1 6 > $1/pipe-read.dat
echo "Generating $1/pipe-write.dat..."
gen_data_rw $1 5 > $1/pipe-write.dat

echo "Generating $1/pipe-*-stddev.dat..."
gen_var $1
