#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-tlbmiss-1-0/output.txt`

get_times() {
    grep "pe01" $1 | awk -v mhz=$mhz '
        /DEBUG 0x1ff10000/ {
            match($1, /^([[:digit:]]+):/, m)
            start=m[1]
        }

        /connector: Injecting IRQ 64/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0) {
                injected=m[1]
            }
        }

        /Microcode_ROM : / {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0 && misshdl == 0) {
                misshdl=m[1]
                if(num > 16) {
                    inject[num] = m[1] - injected
                }
            }
        }

        /CPU-> REQ.*XLATE_RESP/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0 && num > 16) {
                tlbmiss[num] = m[1] - misshdl
            }
            misshdl = 0
        }

        /DEBUG 0x1ff20000/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0 && num > 16) {
                total[num] = m[1] - start
            }
            start = 0
            num += 1
        }

        function ticksToCycles(ticks) {
            return ticks * (mhz / 1000000)
        }

        END {
            for(t in inject) {
                printf("TIME: 0001 : %u\n", ticksToCycles(inject[t]))
            }
            for(t in tlbmiss) {
                printf("TIME: 0002 : %u\n", ticksToCycles(tlbmiss[t]))
            }
            for(t in total) {
                printf("TIME: 0003 : %u\n", ticksToCycles(total[t]))
            }
        }
    '
}

gen_data() {
    fileb=$1/m3-tlbmiss-0-0/gem5.log
    filec=$1/m3-tlbmiss-1-2/gem5.log
    filecs=$1/m3-tlbmiss-1-0/gem5.log

    injc=`get_times $filec | grep 0001 | ./tools/m3-avg.awk`
    injcs=`get_times $filecs | grep 0001 | ./tools/m3-avg.awk`

    missc=`get_times $filec | grep 0002 | ./tools/m3-avg.awk`
    misscs=`get_times $filecs | grep 0002 | ./tools/m3-avg.awk`

    totalb=`get_times $fileb | grep 0003 | ./tools/m3-avg.awk`
    totalc=`get_times $filec | grep 0003 | ./tools/m3-avg.awk`
    totalcs=`get_times $filecs | grep 0003 | ./tools/m3-avg.awk`

    echo "M3-b M3-c M3-c*"
    echo "$totalb $(($totalc - $missc - $injc)) $(($totalcs - $misscs - $injcs))"
    echo "0 $injc $injcs"
    echo "0 $missc $misscs"
}

gen_stddev() {
    fileb=$1/m3-tlbmiss-0-0/gem5.log
    filec=$1/m3-tlbmiss-1-2/gem5.log
    filecs=$1/m3-tlbmiss-1-0/gem5.log

    b=`get_times $fileb | grep 0003 | ./tools/m3-stddev.awk`
    c=`get_times $filec | grep 0003 | ./tools/m3-stddev.awk`
    cs=`get_times $filecs | grep 0003 | ./tools/m3-stddev.awk`

    echo "$b $c $cs"
}

gen_data $1 > $1/tlbmiss.dat
gen_stddev $1 > $1/tlbmiss-stddev.dat
