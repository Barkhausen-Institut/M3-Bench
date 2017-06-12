#!/bin/sh

. tools/helper.sh

mhz=`get_mhz $1/m3-pagefaults-0-0/output.txt`

gen_results() {
    lx=`grep "^\[pf\] $2" $1/lx-pagefaults/res.txt | cut -d ' ' -f 3`
    m300=`./tools/m3-bench.sh time $3 $mhz 5 < $1/m3-pagefaults-0-0/gem5.log`
    m310=`./tools/m3-bench.sh time $3 $mhz 5 < $1/m3-pagefaults-1-0/gem5.log`
    m311=`./tools/m3-bench.sh time $3 $mhz 5 < $1/m3-pagefaults-1-1/gem5.log`
    m312=`./tools/m3-bench.sh time $3 $mhz 5 < $1/m3-pagefaults-1-2/gem5.log`
    echo "$lx $m300 $m310 $m311 $m312" > $1/pagefaults-$2-times.dat

    lx=`grep "^\[pf\] $2" $1/lx-pagefaults/res.txt | cut -d ' ' -f 4 | sed -e 's/(\(.*\))/\1/g'`
    m300=`./tools/m3-bench.sh stddev $3 $mhz 5 < $1/m3-pagefaults-0-0/gem5.log`
    m310=`./tools/m3-bench.sh stddev $3 $mhz 5 < $1/m3-pagefaults-1-0/gem5.log`
    m311=`./tools/m3-bench.sh stddev $3 $mhz 5 < $1/m3-pagefaults-1-1/gem5.log`
    m312=`./tools/m3-bench.sh stddev $3 $mhz 5 < $1/m3-pagefaults-1-2/gem5.log`
    echo "$lx $m300 $m310 $m311 $m312" > $1/pagefaults-$2-stddev.dat
}

gen_results $1 anon 0000
gen_results $1 file 0001

Rscript plots/pagefaults/plot.R $1/pagefaults-anon.pdf \
    $1/pagefaults-anon-times.dat \
    $1/pagefaults-anon-stddev.dat

Rscript plots/pagefaults/plot.R $1/pagefaults-file.pdf \
    $1/pagefaults-file-times.dat \
    $1/pagefaults-file-stddev.dat
