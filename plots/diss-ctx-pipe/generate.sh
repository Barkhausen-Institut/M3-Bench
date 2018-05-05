#!/bin/sh

. tools/helper.sh

mhz=`get_mhz $1/m3-pipe-ctx-alone-cat-wc-512/output.txt`

m3_avg() {
    # gem5 crashed
    if [ "$2-$3-$4-$5" = "shared-all-rand-wc-4096" ]; then
        ./tools/m3-bench.sh time 1234 $mhz 0 < $1/m3-pipe-ctx-$2-$3-$4-$5/gem5.log
    else
        ./tools/m3-bench.sh time 1234 $mhz 1 < $1/m3-pipe-ctx-$2-$3-$4-$5/gem5.log
    fi
}
m3_stddev() {
    if [ "$2-$3-$4-$5" = "shared-all-rand-wc-4096" ]; then
        echo 0
    else
        ./tools/m3-bench.sh stddev 1234 $mhz 1 < $1/m3-pipe-ctx-$2-$3-$4-$5/gem5.log
    fi
}
lx_avg() {
    # linux crashed; just take the last one
    if [ "$2-$3-$4" = "rand-wc-2048" ] || [ "$2-$3-$4" = "rand-sink-1024" ]; then
        ./m3/src/tools/bench.sh $1/lx-pipe-ctx-$2-$3-$4/gem5.log 3000 3 | grep 1234 | cut -d ' ' -f 4
    else
        ./tools/m3-bench.sh time 1234 $mhz 1 < $1/lx-pipe-ctx-$2-$3-$4/gem5.log
    fi
}
lx_stddev() {
    if [ "$2-$3-$4" = "rand-wc-2048" ] || [ "$2-$3-$4" = "rand-sink-1024" ]; then
        echo 0
    else
        ./tools/m3-bench.sh stddev 1234 $mhz 1 < $1/lx-pipe-ctx-$2-$3-$4/gem5.log
    fi
}

for wr in cat rand; do
    for rd in sink wc; do
        echo -n > $1/ctx-pipe-$wr-$rd.dat
        echo -n > $1/ctx-pipe-$wr-$rd-stddev.dat
        echo "Generating times and stddev for $wr-$rd..."
        for sz in 512 1024 2048 4096; do
            lx=`lx_avg $1 $wr $rd $sz`
            m3sh=`m3_avg $1 shared $wr $rd $sz`
            m3shfs=`m3_avg $1 shared-m3fs $wr $rd $sz`
            m3shall=`m3_avg $1 shared-all $wr $rd $sz`
            m3al=`m3_avg $1 alone $wr $rd $sz`
            echo $lx $m3shall $m3sh $m3shfs $m3al >> $1/ctx-pipe-$wr-$rd.dat

            lx=`lx_stddev $1 $wr $rd $sz`
            m3sh=`m3_stddev $1 shared $wr $rd $sz`
            m3shfs=`m3_stddev $1 shared-m3fs $wr $rd $sz`
            m3shall=`m3_stddev $1 shared-all $wr $rd $sz`
            m3al=`m3_stddev $1 alone $wr $rd $sz`
            echo $lx $m3shall $m3sh $m3shfs $m3al >> $1/ctx-pipe-$wr-$rd-stddev.dat
        done
    done
done

for wr in cat rand; do
    for rd in sink wc; do
        echo -n > $1/ctx-pipe-$wr-$rd-1pe.dat
        echo -n > $1/ctx-pipe-$wr-$rd-1pe-stddev.dat
        echo "Generating times and stddev for $wr-$rd-1pe..."
        for sz in 512 1024 2048 4096; do
            lx=`lx_avg $1 1pe-$wr $rd $sz`
            m3sh=`m3_avg $1 shared-1pe $wr $rd $sz`
            echo $lx $m3sh >> $1/ctx-pipe-$wr-$rd-1pe.dat

            lx=`lx_stddev $1 1pe-$wr $rd $sz`
            m3sh=`m3_stddev $1 shared-1pe $wr $rd $sz`
            echo $lx $m3sh >> $1/ctx-pipe-$wr-$rd-1pe-stddev.dat
        done
    done
done

Rscript plots/diss-ctx-pipe/plot.R $1/eval-ctx-pipe.pdf \
    $1/ctx-pipe-rand-wc.dat $1/ctx-pipe-rand-wc-stddev.dat \
    $1/ctx-pipe-rand-sink.dat $1/ctx-pipe-rand-sink-stddev.dat \
    $1/ctx-pipe-cat-wc.dat $1/ctx-pipe-cat-wc-stddev.dat \
    $1/ctx-pipe-cat-sink.dat $1/ctx-pipe-cat-sink-stddev.dat

Rscript plots/diss-ctx-pipe/plot-1pe.R $1/eval-ctx-pipe-1pe.pdf \
    $1/ctx-pipe-rand-wc-1pe.dat $1/ctx-pipe-rand-wc-1pe-stddev.dat \
    $1/ctx-pipe-rand-sink-1pe.dat $1/ctx-pipe-rand-sink-1pe-stddev.dat \
    $1/ctx-pipe-cat-wc-1pe.dat $1/ctx-pipe-cat-wc-1pe-stddev.dat \
    $1/ctx-pipe-cat-sink-1pe.dat $1/ctx-pipe-cat-sink-1pe-stddev.dat
