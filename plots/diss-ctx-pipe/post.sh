#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-pipe-ctx-alone-cat-wc-512/output.txt`

get_kernel_load() {
    grep "DEBUG\|pe00" $1 | awk '
        /DEBUG.*1ff11234/ {
            total = 0
            active = 0
        }
        /DEBUG.*1ff11111/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            start=m[1]
            p=1
        }
        /DEBUG.*1ff21111/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            total=m[1] - start
            p=0
        }

        /Suspending CU/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            if (wake + 0 > 0) {
                if (p)
                    active += m[1] - max(start, wake)
                else if(total + 0 > 0)
                    active += (start + total) - max(start, wake)
                wake = 0
            }
        }

        /Waking up CU/ {
            if (p) {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                wake = m[1]
            }
        }

        function max(a, b) {
            if (a > b)
                return a
            else
                return b
        }

        END {
            printf("%f\n", active / total)
        }
    '
}

m3_avg() {
    ./tools/m3-bench.sh time 1234 $mhz 1 < $1/m3-pipe-ctx-$2-$3-$4-$5/gem5.log
}
m3_stddev() {
    ./tools/m3-bench.sh stddev 1234 $mhz 1 < $1/m3-pipe-ctx-$2-$3-$4-$5/gem5.log
}
lx_avg() {
    ./tools/m3-bench.sh time 1234 $mhz 1 < $1/lx-pipe-ctx-$2-$3-$4/gem5.log
}
lx_stddev() {
    ./tools/m3-bench.sh stddev 1234 $mhz 1 < $1/lx-pipe-ctx-$2-$3-$4/gem5.log
}

for wr in cat rand; do
    for rd in sink wc; do
        echo -n > $1/ctx-pipe-$wr-$rd-idle.dat
        echo "Generating idle times for $wr-$rd..."
        for sz in 512 1024 2048 4096; do
            # m3sh=`get_kernel_load $1/m3-pipe-ctx-shared-$wr-$rd-$sz/gem5.log`
            m3shfs=`get_kernel_load $1/m3-pipe-ctx-shared-m3fs-$wr-$rd-$sz/gem5.log`
            m3shall=`get_kernel_load $1/m3-pipe-ctx-shared-all-$wr-$rd-$sz/gem5.log`
            m3al=`get_kernel_load $1/m3-pipe-ctx-alone-$wr-$rd-$sz/gem5.log`
            m31pe=`get_kernel_load $1/m3-pipe-ctx-shared-1pe-$wr-$rd-$sz/gem5.log`
            # if [ "$m3sh" = "" ]; then m3sh=0; fi
            if [ "$m3shfs" = "" ]; then m3shfs=0; fi
            if [ "$m3shall" = "" ]; then m3shall=0; fi
            if [ "$m3al" = "" ]; then m3al=0; fi
            if [ "$m31pe" = "" ]; then m31pe=0; fi
            echo $m3al $m3shfs $m3shall $m31pe >> $1/ctx-pipe-$wr-$rd-idle.dat
        done
    done
done

for wr in cat rand; do
    for rd in sink wc; do
        echo -n > $1/ctx-pipe-$wr-$rd.dat
        echo -n > $1/ctx-pipe-$wr-$rd-stddev.dat
        echo "Generating times and stddev for $wr-$rd..."
        for sz in 512 1024 2048 4096; do
            lx=`lx_avg $1 $wr $rd $sz`
            # m3sh=`m3_avg $1 shared $wr $rd $sz`
            m3shfs=`m3_avg $1 shared-m3fs $wr $rd $sz`
            m3shall=`m3_avg $1 shared-all $wr $rd $sz`
            m3al=`m3_avg $1 alone $wr $rd $sz`
            if [ "$lx" = "" ]; then lx=0; fi
            # if [ "$m3sh" = "" ]; then m3sh=0; fi
            if [ "$m3shfs" = "" ]; then m3shfs=0; fi
            if [ "$m3shall" = "" ]; then m3shall=0; fi
            if [ "$m3al" = "" ]; then m3al=0; fi
            echo $m3al $m3shfs $m3shall $lx >> $1/ctx-pipe-$wr-$rd.dat

            lx=`lx_stddev $1 $wr $rd $sz`
            # m3sh=`m3_stddev $1 shared $wr $rd $sz`
            m3shfs=`m3_stddev $1 shared-m3fs $wr $rd $sz`
            m3shall=`m3_stddev $1 shared-all $wr $rd $sz`
            m3al=`m3_stddev $1 alone $wr $rd $sz`
            if [ "$lx" = "" ]; then lx=0; fi
            # if [ "$m3sh" = "" ]; then m3sh=0; fi
            if [ "$m3shfs" = "" ]; then m3shfs=0; fi
            if [ "$m3shall" = "" ]; then m3shall=0; fi
            if [ "$m3al" = "" ]; then m3al=0; fi
            echo $m3al $m3shfs $m3shall $lx >> $1/ctx-pipe-$wr-$rd-stddev.dat
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
            if [ "$lx" = "" ]; then lx=0; fi
            if [ "$m3sh" = "" ]; then m3sh=0; fi
            echo $m3sh $lx >> $1/ctx-pipe-$wr-$rd-1pe.dat

            lx=`lx_stddev $1 1pe-$wr $rd $sz`
            m3sh=`m3_stddev $1 shared-1pe $wr $rd $sz`
            if [ "$lx" = "" ]; then lx=0; fi
            if [ "$m3sh" = "" ]; then m3sh=0; fi
            echo $m3sh $lx >> $1/ctx-pipe-$wr-$rd-1pe-stddev.dat
        done
    done
done
