#!/bin/sh

. tools/helper.sh

mhz=3000

get_app_idle() {
    grep pe04 $1 | awk '/DEBUG.*1ff10000/ {p=1}; p; /DEBUG.*1ff20000/ {p=0}' | \
        awk -v mhz=$mhz '
            /Suspending CU/ {
                match($1, /^([[:digit:]]+):/, m)
                sus=m[1]
            }

            /Waking up CU/ {
                match($1, /^([[:digit:]]+):/, m)
                if (m[1] - sus > idle)
                    idle = m[1] - sus
                wakeups += 1
            }

            function ticksToCycles(ticks) {
                return ticks * (mhz / 1000000)
            }

            END {
                print(ticksToCycles(idle), wakeups)
            }
        '
}

gen_results() {
    for num in 1 2 3 4; do
        echo -n > $1/accelchain-$num-times.dat
        echo -n > $1/accelchain-$num-idle.dat
        echo -n > $1/accelchain-$num-wakes.dat
        echo -n > $1/accelchain-$num-stddev.dat

        for time in 1024 2048 4096 8192 16384 32768; do
            echo "Generating times and stddev for comp=$time num=$num..."
            m30t=`./tools/m3-bench.sh time 0000 $mhz 1 < $1/m3-accelchain-0-$time-$num/gem5.log`
            m31t=`./tools/m3-bench.sh time 0000 $mhz 1 < $1/m3-accelchain-1-$time-$num/gem5.log`
            echo $m30t >> $1/accelchain-$num-times.dat
            echo $m31t >> $1/accelchain-$num-times.dat
            m30s=`./tools/m3-bench.sh stddev 0000 $mhz 1 < $1/m3-accelchain-0-$time-$num/gem5.log`
            m31s=`./tools/m3-bench.sh stddev 0000 $mhz 1 < $1/m3-accelchain-1-$time-$num/gem5.log`
            echo $m30s $(echo 'print $(( 100. * (1.*'$m30s' / '$m30t') ))' | zsh) >> $1/accelchain-$num-stddev.dat
            echo $m31s $(echo 'print $(( 100. * (1.*'$m31s' / '$m31t') ))' | zsh) >> $1/accelchain-$num-stddev.dat

            # m30=`get_app_idle $1/m3-accelchain-0-$time-$num/gem5.log`
            # m31=`get_app_idle $1/m3-accelchain-1-$time-$num/gem5.log`
            # m30_idle=`echo $m30 | cut -f 1 -d ' '`
            # m30_wakes=`echo $m30 | cut -f 2 -d ' '`
            # m31_idle=`echo $m31 | cut -f 1 -d ' '`
            # m31_wakes=`echo $m31 | cut -f 2 -d ' '`
            # echo "$m30_idle $m31_idle" >> $1/accelchain-$num-idle.dat
            # echo "$m30_wakes $m31_wakes" >> $1/accelchain-$num-wakes.dat
        done
    done
}

gen_results $1

Rscript plots/accelchain/plot.R $1/accelchain.pdf \
    $1/accelchain-1-times.dat \
    $1/accelchain-2-times.dat \
    $1/accelchain-3-times.dat \
    $1/accelchain-4-times.dat
