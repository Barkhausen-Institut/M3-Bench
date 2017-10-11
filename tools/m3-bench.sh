#!/bin/sh

if [ $# -lt 4 ]; then
    echo "Usage: $0 (stddev|time) <id> <mhz> <warmup> [<pe>]" >&2
    exit 1
fi

type=$1
id=$2
mhz=$3
warmup=$4
pe=${5:-1000000}

starttsc="1ff1$id"
stoptsc="1ff2$id"

extract() {
    awk -v warmup=$warmup -v mhz=$mhz -v pe=$pe '
    function stddev(vals, avg) {
        sum = 0
        for(v in vals) {
            sum += (vals[v] - avg) * (vals[v] - avg)
        }
        return sqrt(sum / length(vals))
    }

    function handle(msg, idx, time) {
        if(substr(msg,3,8) == "'$starttsc'") {
            start[idx] = time
        }
        else if(substr(msg,3,8) == "'$stoptsc'") {
            if(counter[idx] >= warmup) {
                times[idx][num[idx]] = strtonum(time) - strtonum(start[idx])
                total[idx] += times[idx][num[idx]]
                num[idx] += 1
            }
            counter[idx] += 1
        }
    }

    function ticksToCycles(ticks) {
        return ticks * (mhz / 1000000)
    }

    /DEBUG [[:xdigit:]]+/ {
        match($1, /^([[:digit:]]+):/, m)
        if(type == "times" || pe != 1000000) {
            match($2, /(cpu|pe)([[:digit:]]+)/, mpe)
            handle($4, mpe[2], ticksToCycles(m[1]))
        }
        else
            handle($4, pe, ticksToCycles(m[1]))
    }

    END {
        for(i in num) {
            if (num[i] > 0)
                printf "PE%d: %d %d\n", i, total[i] / num[i], stddev(times[i], total[i] / num[i])
            else
                print 0, 0
        }
    }
    '
}

extract | grep "PE$pe" | while read line; do
    if [ "$type" = "stddev" ]; then
        echo $line | cut -d ' ' -f 3
    else
        echo $line | cut -d ' ' -f 2
    fi
done
