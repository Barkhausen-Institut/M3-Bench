#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-pipe-spm/output.txt`

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
lx_idle() {
    for f in $1/stats-*; do
        grep "system.cpu$2.\(quiesce\|idle\)Cycles" $f | awk '
            { sum += $2 } END { printf("TIME: 0000 : %u\n", sum) }
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

gen() {
    m3dir=$1/m3-pipe-$2
    m3log=$m3dir/times.log

    m3rdto=`total $m3log 1235 6`
    m3rdxf=`xfer $m3dir 6 | ./tools/m3-avg.awk`
    m3rdid=`m3_idle $m3dir 6 | ./tools/m3-avg.awk`

    m3wrto=`total $m3log 1235 5`
    m3wrxf=`xfer $m3dir 5 | ./tools/m3-avg.awk`
    m3wrid=`m3_idle $m3dir 5 | ./tools/m3-avg.awk`

    m3to=`total $m3log 1234`

    echo "M3 M3-rd M3-wr"
    echo "0 $m3rdxf $m3wrxf"
    echo "0 $(($m3rdto - $m3rdxf - $m3rdid)) $(($m3wrto - $m3wrxf - $m3wrid))"
    echo "0 $m3rdid $m3wrid"
    echo "$m3to 0 0"
}

gen_cmp() {
    lxdir=$1/lx-pipe
    m3dir=$1/m3-pipe-$2

    lxlog=$lxdir/gem5.log
    m3log=$m3dir/times.log

    lxrdto=`total $lxlog 1235 0`
    lxrdxf=`xfer $lxdir 0 | ./tools/m3-avg.awk`
    lxrdos=`os $lxdir 0 | ./tools/m3-avg.awk`
    lxrdid=`lx_idle $lxdir 0 | ./tools/m3-avg.awk`

    lxwrto=`total $lxlog 1235 1`
    lxwrxf=`xfer $lxdir 1 | ./tools/m3-avg.awk`
    lxwros=`os $lxdir 1 | ./tools/m3-avg.awk`
    lxwrid=`lx_idle $lxdir 1 | ./tools/m3-avg.awk`

    lxto=`total $lxlog 1234`

    m3rdto=`total $m3log 1235 6`
    m3rdxf=`xfer $m3dir 6 | ./tools/m3-avg.awk`
    m3rdid=`m3_idle $m3dir 6 | ./tools/m3-avg.awk`

    m3wrto=`total $m3log 1235 5`
    m3wrxf=`xfer $m3dir 5 | ./tools/m3-avg.awk`
    m3wrid=`m3_idle $m3dir 5 | ./tools/m3-avg.awk`

    m3to=`total $m3log 1234`

    echo "Lx Lx-rd Lx-wr M3 M3-rd M3-wr"
    echo "0 $lxrdxf $lxwrxf" \
         "0 $m3rdxf $m3wrxf"
    echo "0 $(($lxrdto - $lxrdxf - $lxrdid)) $(($lxwrto - $lxwrxf - $lxwrid))" \
         "0 $(($m3rdto - $m3rdxf - $m3rdid)) $(($m3wrto - $m3wrxf - $m3wrid))"
    echo "0 $lxrdid $lxwrid 0 $m3rdid $m3wrid"
    echo "$lxto 0 0 $m3to 0 0"
}

gen_var() {
    m3log=$1/m3-pipe-$2/times.log

    m3rdto=`stddev $m3log 1235 6`
    m3wrto=`stddev $m3log 1235 5`
    m3to=`stddev $m3log 1234`

    echo "$m3to $m3rdto $m3wrto"
}

gen_var_cmp() {
    lxlog=$1/lx-pipe/gem5.log
    m3log=$1/m3-pipe-$2/times.log

    lxrdto=`stddev $lxlog 1235 0`
    lxwrto=`stddev $lxlog 1235 1`
    lxto=`stddev $lxlog 1234`

    m3rdto=`stddev $m3log 1235 6`
    m3wrto=`stddev $m3log 1235 5`
    m3to=`stddev $m3log 1234`

    echo "$lxto $lxrdto $lxwrto $m3to $m3rdto $m3wrto"
}

echo "Splitting Linux results..."
csplit -s --prefix="$1/lx-pipe/stats-" $1/lx-pipe/stats.txt "/End Simulation Statistics/+1" "{*}"
csplit -s --prefix="$1/lx-pipe/gem5-" $1/lx-pipe/gem5.log "/DEBUG 0x1ff21234/+1" "{*}"
rm $1/lx-pipe/stats-{08,09} $1/lx-pipe/gem5-08

for c in spm caches near-spm; do
    echo "Splitting M3-$c results..."
    grep "\(Suspending\|Waking\|DEBUG 0x\)" $1/m3-pipe-$c/gem5.log > $1/m3-pipe-$c/times.log
    csplit -s --prefix="$1/m3-pipe-$c/gem5-" $1/m3-pipe-$c/times.log "/DEBUG 0x1ff21234/+1" "{*}"
    rm $1/m3-pipe-$c/gem5-08

    echo "Generating $1/pipe-$c.dat..."
    if [ "$c" = "near-spm" ]; then
        gen $1 $c > $1/pipe-$c.dat
        gen_var $1 $c > $1/pipe-$c-stddev.dat
    else
        gen_cmp $1 $c > $1/pipe-$c.dat
        gen_var_cmp $1 $c > $1/pipe-$c-stddev.dat
    fi
done

Rscript plots/diss-pipe/plot-cmp.R $1/eval-pipe-caches.pdf $1/pipe-caches.dat $1/pipe-caches-stddev.dat
Rscript plots/diss-pipe/plot-cmp.R $1/eval-pipe-cmp.pdf $1/pipe-spm.dat $1/pipe-spm-stddev.dat
Rscript plots/diss-pipe/plot-spm.R $1/eval-pipe-spm.pdf $1/pipe-near-spm.dat $1/pipe-near-spm-stddev.dat

rel_diff() {
    diff=$(($1 < $2 ? $2 - $1 : $1 - $2))
    echo "scale=4;$diff / $1" | bc
}

spmlog=$1/m3-pipe-spm/times.log
cachelog=$1/m3-pipe-caches/times.log
echo "total : $(rel_diff $(total $spmlog 1234) $(total $cachelog 1234))" > $1/pipe-diff.txt
echo "reader: $(rel_diff $(total $spmlog 1235 6) $(total $cachelog 1235 6))" >> $1/pipe-diff.txt
echo "writer: $(rel_diff $(total $spmlog 1235 5) $(total $cachelog 1235 5))" >> $1/pipe-diff.txt
