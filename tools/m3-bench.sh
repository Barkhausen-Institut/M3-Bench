#!/bin/sh

if [ $# -ne 4 ]; then
    echo "Usage: $0 (stddev|time) <id> <mhz> <warmup>" >&2
    exit 1
fi

type=$1
id=$2
mhz=$3
warmup=$4

starttsc="1ff1$id"
stoptsc="1ff2$id"

extract() {
    awk -v warmup=$warmup -v mhz=$mhz '
    function stddev(vals, avg) {
        sum = 0
        for(v in vals) {
            sum += (vals[v] - avg) * (vals[v] - avg)
        }
        return sqrt(sum / length(vals))
    }

    function handle(msg, time) {
        if(substr(msg,3,8) == "'$starttsc'") {
            start = time
        }
        else if(substr(msg,3,8) == "'$stoptsc'") {
            if(counter > warmup) {
                times[num] = strtonum(time) - strtonum(start)
                total += times[num]
                num += 1
            }
            counter += 1
        }
    }

    function ticksToCycles(ticks) {
        return ticks * (mhz / 1000000)
    }

    /DEBUG [[:xdigit:]]+/ {
        match($1, /^([[:digit:]]+):/, m)
        handle($4, ticksToCycles(m[1]))
    }

    END {
        if (num > 0)
            printf "%d %d\n", total / num, stddev(times, total / num)
        else
            print 0, 0
    }
    '
}

res=`extract`
if [ "$type" = "stddev" ]; then
    echo $res | cut -d ' ' -f 2
else
    echo $res | cut -d ' ' -f 1
fi
