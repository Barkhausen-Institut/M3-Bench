#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-pagefaults-1-0-1/output.txt`

gen_results() {
    if [ "$4" = "pagefaults" ]; then
        lx=`grep "^\[pf\] $2" $1/lx-$4/res.txt | cut -d ' ' -f 3`
        m320=0
    else
        lx=`cut -d ' ' -f 1 $1/lx-syscall/res.txt`
        m320=`./tools/m3-bench.sh time $3 $mhz 2 < $1/m3-$4-2-0$5/gem5.log`
    fi
    m310=`./tools/m3-bench.sh time $3 $mhz 2 < $1/m3-$4-1-0$5/gem5.log`
    m312=`./tools/m3-bench.sh time $3 $mhz 2 < $1/m3-$4-1-2$5/gem5.log`
    echo "$lx $m320 $m312 $m310" > $1/$4-$2$5-times.dat

    if [ "$4" = "pagefaults" ]; then
        slx=`grep "^\[pf\] $2" $1/lx-$4/res.txt | cut -d ' ' -f 4 | sed -e 's/(\(.*\))/\1/g'`
        sm320=0
    else
        slx=`cut -d ' ' -f 2 $1/lx-syscall/res.txt`
        sm320=`./tools/m3-bench.sh stddev $3 $mhz 2 < $1/m3-$4-2-0$5/gem5.log`
    fi
    sm310=`./tools/m3-bench.sh stddev $3 $mhz 2 < $1/m3-$4-1-0$5/gem5.log`
    sm312=`./tools/m3-bench.sh stddev $3 $mhz 2 < $1/m3-$4-1-2$5/gem5.log`

    echo $slx $((100. * (($slx * 1.) / $lx)))       > $1/$4-$2$5-stddevs.dat
    if [ "$4" != "pagefaults" ]; then
        echo $sm320 $((100. * (($sm320 * 1.) / $m320))) >> $1/$4-$2$5-stddevs.dat
    else
        echo 0 0 >> $1/$4-$2$5-stddevs.dat
    fi
    echo $sm312 $((100. * (($sm312 * 1.) / $m312))) >> $1/$4-$2$5-stddevs.dat
    echo $sm310 $((100. * (($sm310 * 1.) / $m310))) >> $1/$4-$2$5-stddevs.dat

    echo $slx $sm320 $sm312 $sm310 > $1/$4-$2$5-stddev.dat
}

gen_results $1 sysc 0000 syscall
gen_results $1 anon 0000 pagefaults -1
gen_results $1 file 0001 pagefaults -1
gen_results $1 anon 0000 pagefaults -4
gen_results $1 file 0001 pagefaults -4

Rscript plots/pagefaults/sc-plot.R $1/syscalls.pdf \
    $1/syscall-sysc-times.dat \
    $1/syscall-sysc-stddev.dat

Rscript plots/pagefaults/pf-plot.R $1/pagefaults.pdf \
    $1/pagefaults-anon-1-times.dat \
    $1/pagefaults-anon-1-stddev.dat \
    $1/pagefaults-file-1-times.dat \
    $1/pagefaults-file-1-stddev.dat \
    $1/pagefaults-anon-4-times.dat \
    $1/pagefaults-anon-4-stddev.dat \
    $1/pagefaults-file-4-times.dat \
    $1/pagefaults-file-4-stddev.dat
