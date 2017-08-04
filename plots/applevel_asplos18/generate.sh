#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-fstrace-tar-1-2/output.txt`

handle_m3_files() {
    tmp=`mktemp`
    for f in $1/m3-fstrace-$2-$3/gem5-*; do
        ./m3/src/tools/bench.sh $f $mhz > $tmp
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
        total=`./tools/timedstrace.php total $lxlog-strace $f`
        wait=`./tools/timedstrace.php waittime $lxlog-strace $f`
        echo "TIME: 0000 : $total"
        echo "TIME: bbbb : $wait"
    done
    awk '/Copied/ { printf("TIME: aaaa : %d\n", $5) }' $lxlog
}

gen_results() {
    lxlog=$1/lx-fstrace-$2/res.txt
    handle_lx_files $1 $2 > $1/applevel_asplos18-lx-$2.dat

    lxtota=`grep 'TIME: 0000' $1/applevel_asplos18-lx-$2.dat | tail -n 7 | ./tools/m3-avg.awk`
    lxxfer=`grep 'TIME: aaaa' $1/applevel_asplos18-lx-$2.dat | tail -n 7 | ./tools/m3-avg.awk`
    lxwait=`grep 'TIME: bbbb' $1/applevel_asplos18-lx-$2.dat | tail -n 7 | ./tools/m3-avg.awk`
    # remove the spaces (somehow, zsh puts in spaces there)
    lxxfer=$((lxxfer * 1))
    lxwait=$((lxwait * 1))

    stddev=`grep 'TIME: 0000' $1/applevel_asplos18-lx-$2.dat | tail -n 7 | ./tools/m3-stddev.awk`
    echo $stddev $((100. * (($stddev * 1.) / $lxtota))) >> $1/applevel_asplos18-stddev.dat

    # ./tools/timedstrace.php human $lxlog-strace $lxlog-timings-07 > $lxlog-human

    declare -A m3tota
    declare -A m3xfer

    for t in 2-0 1-2 1-3; do
        log=$1/m3-fstrace-$2-$t/gem5.log
        rm -f $1/m3-fstrace-$2-$t/gem5-*
        csplit -s --prefix="$1/m3-fstrace-$2-$t/gem5-" $log /0x1ff20000/+1 "{*}"
        rm $1/m3-fstrace-$2-$t/gem5-08

        handle_m3_files $1 $2 $t > $1/applevel_asplos18-m3-$2-$t.dat
        m3tota[$t]=`grep 'TIME: 0000' $1/applevel_asplos18-m3-$2-$t.dat | tail -n 7 | ./tools/m3-avg.awk`
        m3xfer[$t]=`grep 'TIME: aaaa' $1/applevel_asplos18-m3-$2-$t.dat | tail -n 7 | ./tools/m3-avg.awk`
        m3xfer[$t]=$((${m3xfer[$t]} * 1))

        stddev=`grep 'TIME: 0000' $1/applevel_asplos18-m3-$2-$t.dat | tail -n 7 | ./tools/m3-stddev.awk`
        echo $stddev $((100. * (($stddev * 1.) / ($m3tota[$t] + $lxwait)))) >> $1/applevel_asplos18-stddev.dat
    done

    echo "Lx M3c-A M3c-C M3c-C*"
    echo $(($lxtota - $lxxfer - $lxwait)) \
         $((${m3tota[2-0]} - ${m3xfer[2-0]})) \
         $((${m3tota[1-2]} - ${m3xfer[1-2]})) \
         $((${m3tota[1-3]} - ${m3xfer[1-3]}))

    echo $lxxfer ${m3xfer[2-0]} ${m3xfer[1-2]} ${m3xfer[1-3]}
    echo $lxwait $lxwait $lxwait $lxwait
}

echo -n > $1/applevel_asplos18-stddev.dat

gen_results $1 "tar"    > $1/applevel_asplos18-tar-times.dat
gen_results $1 "untar"  > $1/applevel_asplos18-untar-times.dat
gen_results $1 "find"   > $1/applevel_asplos18-find-times.dat
gen_results $1 "sqlite" > $1/applevel_asplos18-sqlite-times.dat

Rscript plots/applevel_asplos18/plot.R $1/applevel_asplos18.pdf \
    $1/applevel_asplos18-tar-times.dat \
    $1/applevel_asplos18-untar-times.dat \
    $1/applevel_asplos18-find-times.dat \
    $1/applevel_asplos18-sqlite-times.dat
