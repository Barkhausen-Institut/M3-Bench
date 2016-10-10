#!/bin/bash

extract_times() {
    awk '
    BEGIN {
        times[0] = 0
        times[1] = 0
        times[2] = 0
        times[3] = 0
        times[4] = 0
        count = 0
    }

    /DEBUG.*1ff11234/ {
        p = 1
        match($0, /^([[:digit:]]*):/, res)
        start = res[1]
    }

    /sd -> 3/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            times[0] += res[1] - start
            start = res[1]
            servsend = 1
        }
    }

    /sd -> 9/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            if (servsend)
                times[1] += res[1] - start
            else
                times[0] += res[1] - start
            start = res[1]
        }
    }

    /rv <- 9/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            times[2] += res[1] - start
            start = res[1]
        }
    }

    /pe05.*rv <- 3/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            times[3] += res[1] - start
            start = res[1]
            servreply = 1
        }
    }

    /DEBUG.*1ff21234/ {
        match($0, /^([[:digit:]]+):/, res)
        times[4] += res[1] - start
        count += 1
        p = 0
    }

    END {
        for(i in times) {
            printf "%d\n", times[i] / count
        }
    }' $1/m3-hash-$2.log > $1/m3-hash-$2-bench.log
}

extract_times $1 direct
extract_times $1 indirect

echo "Indirect Direct" > $1/m3-hash.dat
paste -d " " $1/m3-hash-indirect-bench.log $1/m3-hash-direct-bench.log >> $1/m3-hash.dat

Rscript plots/hashaccel/plot.R $1/m3-hash.pdf $1/m3-hash.dat
