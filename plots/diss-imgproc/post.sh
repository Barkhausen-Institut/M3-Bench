#!/bin/zsh

. tools/helper.sh

mhz=3000 #`get_mhz $1/m3-imgproc-0-1-1-1/output.txt`

get_app_idle() {
    awk 'BEGIN {
            count=0
        }

        /pe05.*DEBUG.*1ff10000/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            start = m[1]
            count += 1
            if(count == 2)
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

get_runtime() {
    grep "DEBUG" $1 | ./tools/m3-bench.sh time 0000 $mhz 1
}
get_stddev() {
    grep "DEBUG" $1 | ./tools/m3-bench.sh stddev 0000 $mhz 1
}

for num in 1 2 3 4; do
    echo "Generating small.log for $num..."
    for t in 0 1; do
        grep "DEBUG\|Suspending\|Waking\|rv <-" $1/m3-imgproc-$t-$num-$num-1/gem5.log \
            > $1/m3-imgproc-$t-$num-$num-1/small.log
    done
done

for num in 1 2 3 4; do
    echo -n > $1/imgproc-$num-times.dat
    echo -n > $1/imgproc-$num-stddev.dat
    echo "Generating times for num=$num..."
    for t in 0 1; do
        time=`get_runtime $1/m3-imgproc-$t-$num-$num-1/small.log`
        if [ "$time" = "" ]; then time=1; fi
        echo $time >> $1/imgproc-$num-times.dat
        stddev=`get_stddev $1/m3-imgproc-$t-$num-$num-1/small.log`
        echo $stddev >> $1/imgproc-$num-stddev.dat
    done

    echo -n > $1/imgproc-$num-util.dat
    echo "Generating utilization for num=$num..."
    for t in 0 1; do
        util=`get_app_idle $1/m3-imgproc-$t-$num-$num-1/small.log`
        echo $util >> $1/imgproc-$num-util.dat
    done
done

#for num in 1 2 3 4; do
#    echo -n > $1/imgproc-$num-ctxsw.dat
#    echo "Generating ctxsw overhead for num=$num..."
#    base=`get_runtime $1/m3-imgproc-2-$num-$((num * 2))-1/gem5.log`
#    for ts in 1 2 4; do
#        time=`get_runtime $1/m3-imgproc-1-$num-$((num * 2))-$ts/gem5.log`
#        echo $((($time * 1.0) / $base)) >> $1/imgproc-$num-ctxsw.dat
#    done
#done
