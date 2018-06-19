#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-accelchain-0-512-1/output.txt`

get_app_idle() {
    awk '
        /pe05.*DEBUG.*1ff10000/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            start=m[1]
            p=1
        }
        /pe05.*DEBUG.*1ff20000/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            total=m[1] - start
            p=0
        }

        /Suspending CU/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            match($2, /^pe([[:digit:]]+).*/, pe)
            if (wake[pe[1]] + 0 > 0) {
                if (p)
                    active[pe[1]] += m[1] - max(start, wake[pe[1]])
                else if(total + 0 > 0)
                    active[pe[1]] += (start + total) - max(start, wake[pe[1]])
                wake[pe[1]] = 0
            }
        }

        /Waking up CU/ {
            if (p) {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                match($2, /pe([[:digit:]]+)/, pe)
                wake[pe[1]] = m[1]
            }
        }

        function max(a, b) {
            if (a > b)
                return a
            else
                return b
        }

        END {
            for(i in active)
            {
                if(i + 0 < 6)
                {
                    util += active[i]
                }
            }

            printf("%f\n", util / total)
        }
    ' < $1
}

get_wakeup_freq() {
    grep "pe03\|pe05" $1 | awk '
        /pe05.*DEBUG.*1ff10000/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            p=1
        }
        /pe05.*DEBUG.*1ff20000/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            p=0
        }

        /\[rv <- [[:digit:]]+\]/ {
            if (p) {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                if (last) {
                    diffs[count] += m[1] - last
                    count += 1
                }
                last = m[1]
            }
        }

        END {
            max = 0
            for(i in diffs)
            {
                if(diffs[i] > max)
                    max = diffs[i]
            }

            print(max)
        }
    '
}

for num in 1 2 4 8; do
    for time in 256 512 1024 2048; do
        echo "Generating small.log for $time-$num..."
        for t in 0 1 2; do
            grep "DEBUG\|Suspending\|Waking\|rv <-" $1/m3-accelchain-$t-$time-$num/gem5.log \
                > $1/m3-accelchain-$t-$time-$num/small.log
        done
    done
done

for num in 1 2 4 8; do
    echo -n > $1/accelchain-$num-times.dat

    for time in 256 512 1024 2048; do
        echo "Generating times for comp=$time num=$num..."
        m30t=`./tools/m3-bench.sh time 0000 $mhz 0 < $1/m3-accelchain-0-$time-$num/small.log`
        m31t=`./tools/m3-bench.sh time 0000 $mhz 0 < $1/m3-accelchain-1-$time-$num/small.log`
        m32t=`./tools/m3-bench.sh time 0000 $mhz 0 < $1/m3-accelchain-2-$time-$num/small.log`
        if [ "$m30t" = "" ]; then m30t=1; fi
        if [ "$m31t" = "" ]; then m31t=1; fi
        if [ "$m32t" = "" ]; then m32t=1; fi
        echo $m30t >> $1/accelchain-$num-times.dat
        echo $m32t >> $1/accelchain-$num-times.dat
        echo $m31t >> $1/accelchain-$num-times.dat
    done

    echo -n > $1/accelchain-$num-util.dat
    echo -n > $1/accelchain-$num-sleep.dat

    for time in 256 512 1024 2048; do
        echo "Generating utilization and sleeps for comp=$time num=$num..."

        for t in 0 2 1; do
            util=`get_app_idle $1/m3-accelchain-$t-$time-$num/small.log`
            echo $util >> $1/accelchain-$num-util.dat
        done

        for t in 0 2 1; do
            get_wakeup_freq $1/m3-accelchain-$t-$time-$num/small.log >> $1/accelchain-$num-sleep.dat
        done
    done
done
