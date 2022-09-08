#!/bin/bash

. tools/helper.sh

extract_m3() {
    awk -e '
    function ticksToCycles(ticks) {
        return ticks * (2000 / 1000000)
    }

    /DEBUG 0xdead/ {
        start=int($1)
        waiting=1
    }
    /T03.cpu: suspend contextId/ {
        if(waiting == 1) {
            end=int($1)
            waiting=0
            print("DTU-sleep", "Suspend", ticksToCycles(end - start))
        }
    }
    /T03.cpu: activate contextId/ {
        start=int($1)
        waiting=2
    }
    /DEBUG 0xbeef/ {
        if(waiting == 2) {
            end=int($1)
            waiting=0
            print("DTU-sleep", "Wakeup", ticksToCycles(end - start))
        }
    }
    ' "$1/m3-tcusleep/gem5.log"
}

extract_lx_umwait() {
    awk -e '
    function ticksToCycles(ticks) {
        return ticks * (2000 / 1000000)
    }

    /DEBUG 0xdead/ {
        start=int($1)
        waiting=1
        suspended=0
    }
    /system.cpu0: suspend contextId/ {
        if(waiting == 1) {
            end=int($1)
            waiting=0
            suspended=1
            print("umwait", "Suspend", ticksToCycles(end - start))
        }
    }
    /system.cpu0: activate contextId/ {
        start=int($1)
        waiting=2
    }
    /DEBUG 0xbeef/ {
        if(waiting == 2 && suspended == 1) {
            end=int($1)
            waiting=0
            print("umwait", "Wakeup", ticksToCycles(end - start))
        }
    }
    ' "$1/lx-mwait-x86_64-$2/gem5.log"
}

lx_avg() {
    extract_lx_umwait "$1" 0 | tail -n +20 | grep "$2" | awk '
    {
        sum += $3;
        n += 1
    }
    END {
        printf("%d\n", sum / n)
    }'
}

extract_lx_mwait() {
    wakeup_avg=$(lx_avg "$1" "Wakeup")
    suspend_avg=$(lx_avg "$1" "Suspend")

    awk -v wakeup="$wakeup_avg" -v suspend="$suspend_avg" -e '
    function ticksToCycles(ticks) {
        return ticks * (2000 / 1000000)
    }

    /DEBUG 0xdead/ {
        start=int($1)
        waiting=1
        suspended=0
    }
    /DEBUG 0xaffe/ {
        if(waiting == 1) {
            end=int($1)
            suspended=1
            print("mwait", "Suspend", ticksToCycles(end - start) + suspend)
            start=int($1)
            waiting=2
        }
    }
    /DEBUG 0xbeef/ {
        if(waiting == 2 && suspended == 1) {
            end=int($1)
            waiting=0
            print("mwait", "Wakeup", ticksToCycles(end - start) + wakeup)
        }
    }
    ' "$1/lx-mwait-x86_64-$2/gem5.log"
}

(
    echo "mechanism op latency"
    extract_m3 "$1" | tail -n +20
    extract_lx_umwait "$1" 0 | tail -n +20
    extract_lx_mwait "$1" 1 | tail -n +20
) > "$1/mwait.dat"
