#!/bin/sh
here=$(dirname $(readlink -f $0))

pe="$here/pe_rcv_fib.txt"

awk '
    /xttop_i0/ {
        match($0, /^.*?_([[:digit:]]+)_.log: (.*?): ([0-9\.e-]+)/, m)
        core[m[1]] += m[3]
    }
    /imem_i0|dmem_i0/ {
        match($0, /^.*?_([[:digit:]]+)_.log: (.*?): ([0-9\.e-]+)/, m)
        mem[m[1]] += m[3]
    }
    /idma_i0/ {
        match($0, /^.*?_([[:digit:]]+)_.log: (.*?): ([0-9\.e-]+)/, m)
        # the filter-stuff takes 1.1mW, which we substract here because we dont need it
        dtu[m[1]] += m[3] - 0.0011
    }
    END {
        print("Core SPM DTU")
        for(x in core) {
            print(x, core[x], mem[x], dtu[x])
        }
    }
    ' < $here/pe_rcv_fib.txt > $1/power-fib.dat

Rscript plots/power-fib/plot.R $1/eval-power-fib.pdf $1/power-fib.dat
