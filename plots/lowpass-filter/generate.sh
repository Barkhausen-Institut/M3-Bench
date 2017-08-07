#!/bin/sh

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
                printf("%d cycles, %.3f us, %d wakeups\n", ticksToCycles(idle), idle / 1000000, wakeups)
            }
        '
}

get_app_idle $1/m3-lowpass-filter-0/gem5.log > $1/lowpass-filter.dat
get_app_idle $1/m3-lowpass-filter-1/gem5.log >> $1/lowpass-filter.dat
