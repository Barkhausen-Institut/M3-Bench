#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-fstrace-tar-1-2/output.txt`

handle_m3_files() {
    tmp=`mktemp`
    for f in $1/m3-fstrace-$2-$3/gem5-*; do
        ./m3/src/tools/bench.sh $f $mhz | sed -e 's/^PE4-//g' > $tmp
        grep 'TIME: 0000' $tmp
        grep 'TIME: aaaa' $tmp | awk '{ sum += $4 } END { printf("TIME: aaaa : %u cycles\n", sum) }'
    done

    # while read line; do
    #     no=$(printf "%d\n" "0x$(echo $line | cut -f 2 -d ' ')")
    #     op=$(grep "/* #$no = " $1/lx-fstrace-$2/res.txt-opcodes.c | cut -d ' ' -f 13)
    #     if [ "$op" != "WAITUNTIL_OP," ]; then
    #         printf "%s : %12s : %s\n" $no $op $(echo $line | cut -f 4 -d ' ')
    #     fi
    # done < <(grep -v "cccc\|bbbb\|aaaa" $tmp) > $1/m3-fstrace-$2-$3/human

    rm $tmp
}

handle_lx_files() {
    lxlog=$1/lx-fstrace-$2/res.txt
    for f in $lxlog-timings-0*; do
        total=`./tools/timedstrace.php total $lxlog-strace $f 2>/dev/null`
        wait=`./tools/timedstrace.php waittime $lxlog-strace $f 2>/dev/null`
        echo "TIME: 0000 : $total"
        echo "TIME: bbbb : $wait"
    done
    awk '/Copied/ { printf("TIME: aaaa : %d\n", $5) }' $lxlog
}

gen_results() {
    lxlog=$1/lx-fstrace-$2/res.txt
    handle_lx_files $1 $2 > $1/eval-app-lx-$2.dat

    lxtota=`grep 'TIME: 0000' $1/eval-app-lx-$2.dat | grep -v "Warning in line" | tail -n 3 | ./tools/m3-avg.awk`
    lxxfer=`grep 'TIME: aaaa' $1/eval-app-lx-$2.dat | grep -v "Warning in line" | tail -n 3 | ./tools/m3-avg.awk`
    lxwait=`grep 'TIME: bbbb' $1/eval-app-lx-$2.dat | grep -v "Warning in line" | tail -n 3 | ./tools/m3-avg.awk`
    # remove the spaces (somehow, zsh puts in spaces there)
    lxxfer=$((lxxfer * 1))
    lxwait=$((lxwait * 1))
    if [ "$lxtota" = "" ]; then lxtota=1; fi

    stddev=`grep 'TIME: 0000' $1/eval-app-lx-$2.dat | grep -v "Warning in line" | tail -n 3 | ./tools/m3-stddev.awk`
    if [ "$stddev" = "" ]; then stddev=0; fi
    echo $stddev $((100. * (($stddev * 1.) / $lxtota))) >> $1/eval-app-stddev.dat

    # ./tools/timedstrace.php human $lxlog-strace $lxlog-timings-07 > $lxlog-human

    declare -A m3tota
    declare -A m3xfer

    # for t in 2-0 1-2 1-3; do
    for t in 1-2; do
        log=$1/m3-fstrace-$2-$t/gem5.log
        rm -f $1/m3-fstrace-$2-$t/gem5-*
        csplit -s --prefix="$1/m3-fstrace-$2-$t/gem5-" $log /0x1ff20000/+1 "{*}"
        rm $1/m3-fstrace-$2-$t/gem5-04

        handle_m3_files $1 $2 $t > $1/eval-app-m3-$2-$t.dat
        m3tota[$t]=`grep 'TIME: 0000' $1/eval-app-m3-$2-$t.dat | tail -n 3 | ./tools/m3-avg.awk`
        m3xfer[$t]=`grep 'TIME: aaaa' $1/eval-app-m3-$2-$t.dat | tail -n 3 | ./tools/m3-avg.awk`
        m3xfer[$t]=$((${m3xfer[$t]} * 1))

        stddev=`grep 'TIME: 0000' $1/eval-app-m3-$2-$t.dat | tail -n 3 | ./tools/m3-stddev.awk`
        echo $stddev $((100. * (($stddev * 1.) / ($m3tota[$t] + $lxwait)))) >> $1/eval-app-stddev.dat
    done

    # echo "Lx M3c-A M3c-C M3c-C*"
    # echo $(($lxtota - $lxxfer - $lxwait)) \
    #      $((${m3tota[2-0]} - ${m3xfer[2-0]})) \
    #      $((${m3tota[1-2]} - ${m3xfer[1-2]})) \
    #      $((${m3tota[1-3]} - ${m3xfer[1-3]}))

    # echo $lxxfer ${m3xfer[2-0]} ${m3xfer[1-2]} ${m3xfer[1-3]}
    # echo $lxwait $lxwait $lxwait $lxwait

    echo "Lx M3"
    echo $(($lxtota - $lxxfer - $lxwait)) \
         $((${m3tota[1-2]} - ${m3xfer[1-2]}))

    echo $lxxfer ${m3xfer[1-2]}
    echo $lxwait $lxwait
}

# echo -n > $1/eval-app-stddev.dat
# for tr in tar untar sha256sum sort find sqlite leveldb; do
#     echo "Generating eval-$tr-times.dat..."
#     gen_results $1 $tr > $1/eval-app-$tr-times.dat
# done

rscript_crop plots/diss-app/plot.R $1/eval-app.pdf \
    $1/eval-app-tar-times.dat \
    $1/eval-app-untar-times.dat \
    $1/eval-app-sha256sum-times.dat \
    $1/eval-app-sort-times.dat \
    $1/eval-app-find-times.dat \
    $1/eval-app-sqlite-times.dat \
    $1/eval-app-leveldb-times.dat
