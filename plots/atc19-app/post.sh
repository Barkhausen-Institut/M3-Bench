#!/bin/zsh

. tools/helper.sh

mhz=`get_mhz $1/m3-fstrace-tar-new/output.txt`

handle_m3_files() {
    rm -f $1/m3-fstrace-$2-$3/gem5-*
    csplit -s --prefix="$1/m3-fstrace-$2-$3/gem5-" $1/m3-fstrace-$2-$3/gem5.log /0x1ff20000/+1 "{*}"
    rm $1/m3-fstrace-$2-$3/gem5-04

    tmp=`mktemp`
    tmp2=`mktemp`
    for f in $1/m3-fstrace-$2-$3/gem5-*; do
        awk '
            /DEBUG.*1ff10000/ { p=1; print($0) }
            /DEBUG.*1ff20000/ { p=0; print($0) }
            { if(p) print($0) }
        ' < $f > $tmp2
        ./m3/src/tools/bench.sh $tmp2 $mhz | sed -e 's/^PE4-//g' > $tmp
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

    rm $tmp $tmp2
}

handle_lx_files() {
    lxlog=$1/lx-fstrace-$2/res.txt
    for f in $lxlog-timings-0*; do
        if [ "$2" = "sort" ]; then
            args="--trace-stdout"
        else
            args=""
        fi
        total=`./tools/timedstrace.php total $lxlog-strace $f $args 2>/dev/null`
        wait=`./tools/timedstrace.php waittime $lxlog-strace $f $args 2>/dev/null`
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
    echo "Lx-$2:" $stddev $((100. * (($stddev * 1.) / $lxtota))) >> $1/eval-app-stddev.dat

    handle_m3_files $1 $2 old > $1/eval-app-m3-$2-old.dat
    handle_m3_files $1 $2 new > $1/eval-app-m3-$2-new.dat

    m3tota_old=`grep 'TIME: 0000' $1/eval-app-m3-$2-old.dat | tail -n 3 | ./tools/m3-avg.awk`
    m3xfer_old=`grep 'TIME: aaaa' $1/eval-app-m3-$2-old.dat | tail -n 3 | ./tools/m3-avg.awk`
    m3xfer_old=$(($m3xfer_old * 1))

    stddev_old=`grep 'TIME: 0000' $1/eval-app-m3-$2-old.dat | tail -n 3 | ./tools/m3-stddev.awk`
    echo "M3-old-$2:" $stddev_old $((100. * (($stddev_old * 1.) / ($m3tota_old + $lxwait)))) >> $1/eval-app-stddev.dat

    m3tota_new=`grep 'TIME: 0000' $1/eval-app-m3-$2-new.dat | tail -n 3 | ./tools/m3-avg.awk`
    m3xfer_new=`grep 'TIME: aaaa' $1/eval-app-m3-$2-new.dat | tail -n 3 | ./tools/m3-avg.awk`
    m3xfer_new=$(($m3xfer_new * 1))

    stddev_new=`grep 'TIME: 0000' $1/eval-app-m3-$2-new.dat | tail -n 3 | ./tools/m3-stddev.awk`
    echo "M3-new-$2:" $stddev_new $((100. * (($stddev_new * 1.) / ($m3tota_new + $lxwait)))) >> $1/eval-app-stddev.dat

    echo "Lx M3-old M3-new"
    echo $(($lxtota - $lxxfer - $lxwait)) \
         $(($m3tota_old - $m3xfer_old)) \
         $(($m3tota_new - $m3xfer_new))
    echo $lxxfer $m3xfer_old $m3xfer_new
    echo $lxwait $lxwait $lxwait
}

echo -n > $1/eval-app-stddev.dat
for tr in tar untar sha256sum sort find sqlite leveldb; do
    echo "Generating eval-$tr-times.dat..."
    gen_results $1 $tr > $1/eval-app-$tr-times.dat
done

for tr in tar untar sha256sum sort find sqlite leveldb; do
    echo -n "$tr: "
    ./tools/timedstrace.php total \
        $1/lx-fstrace-$tr/res.txt-strace \
        $1/lx-fstrace-$tr/res.txt-timings-03 2>&1 | grep Ignored
done
