#!/bin/zsh

# set -x

. tools/helper.sh

cfg=b-riscv
mhz=`get_mhz $1/m3-tests-tar-$cfg-64/output.txt`

handle_m3_files() {
    tmp=`mktemp`
    for f in $1/m3-tests-$2-$3/gem5-*; do
        ./m3/src/tools/bench.sh $mhz < $f | sed -e 's/^PE.*-//g' > $tmp
        grep 'TIME: 0000' $tmp
        grep 'TIME: aaaa' $tmp | awk '{ sum += $4 } END { printf("TIME: aaaa : %u cycles\n", sum) }'
    done

    # while read line; do
    #     no=$(printf "%d\n" "0x$(echo $line | cut -f 2 -d ' ')")
    #     op=$(grep "/* #$no = " $1/lx-fstrace-$2/res.txt-opcodes.c | cut -d ' ' -f 13)
    #     if [ "$op" != "WAITUNTIL_OP," ]; then
    #         printf "%s : %12s : %s\n" $no $op $(echo $line | cut -f 4 -d ' ')
    #     fi
    # done < <(grep -v "cccc\|bbbb\|aaaa" $tmp) > $1/m3-tests-$2-$3/human

    rm $tmp
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

    declare -A m3tota
    declare -A m3xfer

    t=$cfg-64
    log=$1/m3-tests-$2-$t/gem5.log.gz
    rm -f $1/m3-tests-$2-$t/gem5-*
    zcat $log | csplit -s --prefix="$1/m3-tests-$2-$t/gem5-" - /0x1ff20000/+1 "{*}"
    rm $1/m3-tests-$2-$t/gem5-{04,05}

    handle_m3_files $1 $2 $t > $1/eval-app-m3-$2-$t.dat
    m3tota=`grep 'TIME: 0000' $1/eval-app-m3-$2-$t.dat | tail -n 3 | ./tools/m3-avg.awk`
    m3xfer=`grep 'TIME: aaaa' $1/eval-app-m3-$2-$t.dat | tail -n 3 | ./tools/m3-avg.awk`
    m3xfer=$(($m3xfer * 1))

    stddev=`grep 'TIME: 0000' $1/eval-app-m3-$2-$t.dat | tail -n 3 | ./tools/m3-stddev.awk`
    echo "M3-$2:" $stddev $((100. * (($stddev * 1.) / ($m3tota + $lxwait)))) >> $1/eval-app-stddev.dat

    echo "Lx M3"
    echo $(($lxtota - $lxxfer - $lxwait)) \
         $(($m3tota - $m3xfer))

    echo $lxxfer $m3xfer
    echo $lxwait $lxwait
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
