#!/bin/zsh

. tools/helper.sh

mhz=3000

m3_idle() {
    for f in $1/gem5-*; do
        grep "pe0$2" $f | awk -v mhz=$mhz '
            /Suspending CU/ {
                match($1, /^([[:digit:]]+):/, m)
                sus=m[1]
            }

            /Waking up CU/ {
                match($1, /^([[:digit:]]+):/, m)
                if (sus != 0)
                    idle += m[1] - sus
            }

            function ticksToCycles(ticks) {
                return ticks * (mhz / 1000000)
            }

            END {
                printf("TIME: 0000 : %u\n", ticksToCycles(idle))
            }
        '
    done | tail -n 3 | ./tools/m3-avg.awk
}
lx_idle() {
    for f in $1/stats-*; do
        grep "system.cpu$2.\(quiesce\|idle\)Cycles" $f | awk '
            { sum += $2 } END { printf("TIME: 0000 : %u\n", sum) }
        '
    done | tail -n 3 | ./tools/m3-avg.awk
}

get_lx_time() {
    ./tools/timedstrace.php $5 $1/$2_$3_$4-1024.txt-strace \
                               $1/$2_$3_$4-1024.txt-timings-00 --trace-stdout 2>/dev/null
}

get_results() {
    csplit -s --prefix="$1/lx-pipe-fstrace-0-$2-$3-1024/stats-" \
        $1/lx-pipe-fstrace-0-$2-$3-1024/stats.txt "/End Simulation Statistics/+1" "{*}"
    rm -f $1/lx-pipe-fstrace-0-$2-$3-1024/stats-{04,05}

    rm -f $1/m3-fstrace-pipe-$2-$3/gem5-*
    csplit -s --prefix="$1/m3-fstrace-pipe-$2-$3/gem5-" $1/m3-fstrace-pipe-$2-$3/gem5.log /0x1ff21235/+1 "{*}"
    rm $1/m3-fstrace-pipe-$2-$3/gem5-04

    lxtotal=`./m3/src/tools/bench.sh $1/lx-pipe-fstrace-0-$2-$3-1024/gem5.log $mhz 0 | \
                grep 'TIME: 1234' | tail -n 3 | ./tools/m3-avg.awk`
    lxstddev=`./m3/src/tools/bench.sh $1/lx-pipe-fstrace-0-$2-$3-1024/gem5.log $mhz 0 | \
                grep 'TIME: 1234' | tail -n 3 | ./tools/m3-stddev.awk`
    echo "Lx-$2-$3:" $lxstddev $((100. * (($lxstddev * 1.) / $lxtotal))) >> $1/eval-app-pipe-stddev.dat

    m3total=`./m3/src/tools/bench.sh $1/m3-fstrace-pipe-$2-$3/gem5.log $mhz 0 | \
                grep "TIME: 1235" | tail -n 3 | ./tools/m3-avg.awk`
    m3stddev=`./m3/src/tools/bench.sh $1/m3-fstrace-pipe-$2-$3/gem5.log $mhz 0 | \
                grep "TIME: 1235" | tail -n 3 | ./tools/m3-stddev.awk`
    echo "M3-$2-$3:" $m3stddev $((100. * (($m3stddev * 1.) / $m3total))) >> $1/eval-app-pipe-stddev.dat

    lxtotalwr=`get_lx_time $1 $2 $3 $2 total`
    lxtotalrd=`get_lx_time $1 $2 $3 $3 total`
    lxidlerd=`lx_idle $1/lx-pipe-fstrace-0-$2-$3-1024 0`
    m3totalrd=`./m3/src/tools/bench.sh $1/m3-fstrace-pipe-$2-$3/gem5.log $mhz 0 | \
                grep "PE6-TIME: 0000" | tail -n 3 | ./tools/m3-avg.awk`
    m3idlerd=`m3_idle $1/m3-fstrace-pipe-$2-$3 6`

    lxwaitwr=`get_lx_time $1 $2 $3 $2 waittime`
    lxwaitrd=`get_lx_time $1 $2 $3 $3 waittime`
    lxidlewr=`lx_idle $1/lx-pipe-fstrace-0-$2-$3-1024 1`
    m3totalwr=`./m3/src/tools/bench.sh $1/m3-fstrace-pipe-$2-$3/gem5.log $mhz 0 | \
                grep "PE5-TIME: 0000" | tail -n 3 | ./tools/m3-avg.awk`
    m3idlewr=`m3_idle $1/m3-fstrace-pipe-$2-$3 5`

    echo "Lx M3 Lx-wr M3-wr Lx-rd M3-rd"
    echo $lxtotal $m3total 0 0 0 0
    echo 0 0 $(($lxtotalwr - $lxwaitwr - $lxidlewr)) $((m3totalwr - $lxwaitwr - $m3idlewr)) \
             $(($lxtotalrd - $lxwaitrd - $lxidlerd)) $((m3totalrd - $lxwaitrd - $m3idlerd))
    echo 0 0 $lxidlewr $m3idlewr $lxidlerd $m3idlerd
    echo 0 0 $lxwaitwr $lxwaitwr $lxwaitrd $lxwaitrd
}

echo -n > $1/eval-app-pipe-stddev.dat
for tr1 in cat grep; do
    for tr2 in awk wc; do
        echo "Generating eval-app-pipe-$tr1-$tr2.dat..."
        get_results $1 $tr1 $tr2 > $1/eval-app-pipe-$tr1-$tr2.dat
    done
done

rscript_crop plots/diss-app-pipe/plot.R $1/eval-app-pipe.pdf \
    $1/eval-app-pipe-cat-awk.dat \
    $1/eval-app-pipe-cat-wc.dat \
    $1/eval-app-pipe-grep-awk.dat \
    $1/eval-app-pipe-grep-wc.dat
