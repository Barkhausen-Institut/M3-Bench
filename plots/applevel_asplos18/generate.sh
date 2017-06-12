#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-fstrace-tar-0-0/output.txt`

sum_time() {
    awk '{ sum += $4 } END { printf("%u\n", sum) }'
}

gen_results() {
    lxlog=$1/lx-fstrace-$2/res.txt

    lxtota=`./tools/timedstrace.php total $lxlog-strace $lxlog-timings`
    lxxfer=`awk '/Copied/ { print $5 }' $lxlog`
    lxwait=`./tools/timedstrace.php waittime $lxlog-strace $lxlog-timings`

    log00=$1/m3-fstrace-$2-5-0-0/gem5.log
    log10=$1/m3-fstrace-$2-1-0/gem5.log
    log11=$1/m3-fstrace-$2-1-1/gem5.log
    log12=$1/m3-fstrace-$2-1-2/gem5.log

    m3tota00=`./m3/src/tools/bench.sh $log00 $mhz | grep 'TIME: 0000' | ./tools/m3-avg.awk`
    m3xfer00=`./m3/src/tools/bench.sh $log00 $mhz | grep 'TIME: aaaa' | sum_time`
    m3wait00=`./m3/src/tools/bench.sh $log00 $mhz | grep 'TIME: bbbb' | sum_time`

    m3tota10=`./m3/src/tools/bench.sh $log10 $mhz | grep 'TIME: 0000' | ./tools/m3-avg.awk`
    m3xfer10=`./m3/src/tools/bench.sh $log10 $mhz | grep 'TIME: aaaa' | sum_time`
    m3wait10=`./m3/src/tools/bench.sh $log10 $mhz | grep 'TIME: bbbb' | sum_time`

    m3tota11=`./m3/src/tools/bench.sh $log11 $mhz | grep 'TIME: 0000' | ./tools/m3-avg.awk`
    m3xfer11=`./m3/src/tools/bench.sh $log11 $mhz | grep 'TIME: aaaa' | sum_time`
    m3wait11=`./m3/src/tools/bench.sh $log11 $mhz | grep 'TIME: bbbb' | sum_time`

    m3tota12=`./m3/src/tools/bench.sh $log12 $mhz | grep 'TIME: 0000' | ./tools/m3-avg.awk`
    m3xfer12=`./m3/src/tools/bench.sh $log12 $mhz | grep 'TIME: aaaa' | sum_time`
    m3wait12=`./m3/src/tools/bench.sh $log12 $mhz | grep 'TIME: bbbb' | sum_time`

    echo "M300 M310 M311 M312 Lx"
    echo $(($m3tota00 - $m3xfer00 - $m3wait00)) \
         $(($m3tota10 - $m3xfer10 - $m3wait10)) \
         $(($m3tota11 - $m3xfer11 - $m3wait11)) \
         $(($m3tota12 - $m3xfer12 - $m3wait12)) \
         $(($lxtota - $lxxfer - $lxwait))
    echo $m3xfer00 $m3xfer10 $m3xfer11 $m3xfer12 $lxxfer
    echo $m3wait00 $m3wait10 $m3wait11 $m3wait12 $lxwait
}

gen_results $1 "tar"    > $1/applevel_asplos18-tar-times.dat
gen_results $1 "untar"  > $1/applevel_asplos18-untar-times.dat
gen_results $1 "find"   > $1/applevel_asplos18-find-times.dat
gen_results $1 "sqlite" > $1/applevel_asplos18-sqlite-times.dat

Rscript plots/applevel_asplos18/plot.R $1/applevel_asplos18.pdf \
    $1/applevel_asplos18-tar-times.dat \
    $1/applevel_asplos18-untar-times.dat \
    $1/applevel_asplos18-find-times.dat \
    $1/applevel_asplos18-sqlite-times.dat
