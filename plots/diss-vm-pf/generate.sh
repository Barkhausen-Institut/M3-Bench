#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-pagefaults-1-0-anon-1/output.txt`

get_times() {
    awk -v mhz=$mhz '
        /DEBUG 0x1ff1000/ {
            match($1, /^([[:digit:]]+):/, m)
            start=m[1]
        }

        /pe00.dtu:.*rv <- 2/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0) {
                pkstart=m[1]
            }
        }

        /pe00.dtu:.*rp -> 2/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0 && num >= 4) {
                pkernel[num] += m[1] - pkstart
            }
        }

        /pe00.dtu:.*rv <- 1/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0) {
                mkstart=m[1]
            }
        }

        /pe00.dtu:.*rp -> 1/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0 && num >= 4) {
                mkernel[num] += m[1] - mkstart
            }
        }

        /pe01.dtu:.*rv <-.*on EP5/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0) {
                mstart=m[1]
            }
        }

        /pe01.dtu:.*rp ->/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0 && num >= 4) {
                m3fs[num] += m[1] - mstart
            }
        }

        /pe02.dtu:.*rv <- 4/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0) {
                pstart=m[1]
            }
        }

        /pe02.dtu:.*rp -> 4/ {
            match($1, /^([[:digit:]]+):/, m)
            if(start != 0 && num >= 4) {
                pager[num] += m[1] - pstart
            }
        }

        /DEBUG 0x1ff2000/ {
            match($1, /^([[:digit:]]+):/, m)
            start = 0
            if(num < 4 || pager[num] != 0) {
                num += 1
            }
        }

        function ticksToCycles(ticks) {
            return ticks * (mhz / 1000000)
        }

        END {
            for(t in pkernel) {
                if(pkernel[t] > 0) {
                    printf("TIME: 0000 : %u\n", ticksToCycles(pkernel[t]))
                }
            }
            for(t in mkernel) {
                if(mkernel[t] > 0) {
                    printf("TIME: 0001 : %u\n", ticksToCycles(mkernel[t]))
                }
            }
            for(t in m3fs) {
                if(m3fs[t] > 0) {
                    printf("TIME: 0002 : %u\n", ticksToCycles(m3fs[t]))
                }
            }
            for(t in pager) {
                if(pager[t] > 0) {
                    printf("TIME: 0003 : %u\n", ticksToCycles(pager[t]))
                }
            }
        }
    ' < $1
}

gen_data() {
    fileb=$1/m3-pagefaults-0-0-$2/gem5.log
    filec=$1/m3-pagefaults-1-2-$2/gem5.log
    filecs=$1/m3-pagefaults-1-0-$2/gem5.log

    name=${2::-2}
    lx=`grep "^\[pf\] $name" $1/lx-pagefaults/res.txt | cut -d ' ' -f 3`

    pkb=`get_times $fileb | grep 0000 | ./tools/m3-avg.awk`
    pkc=`get_times $filec | grep 0000 | ./tools/m3-avg.awk`
    pkcs=`get_times $filecs | grep 0000 | ./tools/m3-avg.awk`

    if [ "$2" = "file-1" ] || [ "$2" = "file-4" ]; then
        mkb=`get_times $fileb | grep 0001 | ./tools/m3-avg.awk`
        mkc=`get_times $filec | grep 0001 | ./tools/m3-avg.awk`
        mkcs=`get_times $filecs | grep 0001 | ./tools/m3-avg.awk`

        m3fsb=`get_times $fileb | grep 0002 | ./tools/m3-avg.awk`
        m3fsc=`get_times $filec | grep 0002 | ./tools/m3-avg.awk`
        m3fscs=`get_times $filecs | grep 0002 | ./tools/m3-avg.awk`
    else
        mkb=0; mkc=0; mkcs=0;
        m3fsb=0; m3fsc=0; m3fscs=0;
    fi

    pagerb=`get_times $fileb | grep 0003 | ./tools/m3-avg.awk`
    pagerc=`get_times $filec | grep 0003 | ./tools/m3-avg.awk`
    pagercs=`get_times $filecs | grep 0003 | ./tools/m3-avg.awk`

    totalb=`./tools/m3-bench.sh time 00ff $mhz 0 < $fileb`
    totalc=`./tools/m3-bench.sh time 00ff $mhz 0 < $filec`
    totalcs=`./tools/m3-bench.sh time 00ff $mhz 0 < $filecs`

    if [ "$2" = "anon-4" ] || [ "$2" = "file-4" ]; then
        pkb=$(($pkb / 4)); pkc=$(($pkc / 4)); pkcs=$(($pkcs / 4))
        mkb=$(($mkb / 4)); mkc=$(($mkc / 4)); mkcs=$(($mkcs / 4))
        m3fsb=$(($m3fsb / 4)); m3fsc=$(($m3fsc / 4)); m3fscs=$(($m3fscs / 4))
        pagerb=$(($pagerb / 4)); pagerc=$(($pagerc / 4)); pagercs=$(($pagercs / 4))
    fi

    echo "Lx M3-b M3-c M3-c*"
    echo "0 $(($totalb / 64 - $pagerb)) $(($totalc / 64 - $pagerc)) $(($totalcs / 64 - $pagercs))"
    echo "0 $(($pagerb - $pkb)) $(($pagerc - $pkc)) $(($pagercs - $pkcs))"
    echo "0 $(($m3fsb - $mkb)) $(($m3fsc - $mkc)) $(($m3fscs - $mkcs))"
    echo "$((lx / 64)) $(($pkb + $mkb)) $(($pkc + $mkc)) $(($pkcs + $mkcs))"
}

gen_stddev() {
    fileb=$1/m3-pagefaults-0-0-$2/gem5.log
    filec=$1/m3-pagefaults-1-2-$2/gem5.log
    filecs=$1/m3-pagefaults-1-0-$2/gem5.log

    name=${2::-2}
    lx=`grep "^\[pf\] $name" $1/lx-pagefaults/res.txt | cut -d ' ' -f 4 | sed -e 's/(\(.*\))/\1/g'`

    totalb=`./tools/m3-bench.sh stddev 00ff $mhz 0 < $fileb`
    totalc=`./tools/m3-bench.sh stddev 00ff $mhz 0 < $filec`
    totalcs=`./tools/m3-bench.sh stddev 00ff $mhz 0 < $filecs`

    echo "$((lx / 64)) $((totalb / 64)) $((totalc / 64)) $((totalcs / 64))"
}

for type in anon-1 anon-4 file-1 file-4; do
    gen_data $1 $type > $1/$type-times.dat
    gen_stddev $1 $type > $1/$type-stddev.dat
done

Rscript plots/diss-vm-pf/plot.R $1/eval-pagefaults.pdf \
    $1/anon-1-times.dat \
    $1/anon-1-stddev.dat \
    $1/file-1-times.dat \
    $1/file-1-stddev.dat \
    $1/anon-4-times.dat \
    $1/anon-4-stddev.dat \
    $1/file-4-times.dat \
    $1/file-4-stddev.dat
