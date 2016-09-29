#!/bin/bash

extract_times() {
    awk '
    /DEBUG.*1ff11234/ {
        p = 1
        match($0, /^([[:digit:]]*):/, res)
        start = res[1]
    }

    /sd -> 3/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            print(res[1] - start)
            start = res[1]
            servsend = 1
        }
    }

    /sd -> 9/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            print(res[1] - start)
            if (!servsend)
                print(0)
            start = res[1]
        }
    }

    /rv <- 9/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            print(res[1] - start)
            start = res[1]
        }
    }

    /pe05.*rv <- 3/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            print(res[1] - start)
            start = res[1]
            servreply = 1
        }
    }

    /DEBUG.*1ff21234/ {
        match($0, /^([[:digit:]]+):/, res)
        if (!servreply)
            print(0)
        print(res[1] - start)
        p = 0
    }' $1/m3-hash-$2.log > $1/m3-hash-$2-bench.log
}

extract_times $1 direct
extract_times $1 indirect

echo "Direct Indirect" > $1/m3-hash.dat
paste -d " " $1/m3-hash-direct-bench.log $1/m3-hash-indirect-bench.log >> $1/m3-hash.dat

Rscript plots/hashaccel/plot.R $1/m3-hash.pdf $1/m3-hash.dat
