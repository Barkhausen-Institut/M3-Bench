#!/bin/bash

. tools/helper.sh

m3bpe=128
mhz=`get_mhz $1/m3-fs-read-a-$m3bpe/output.txt`

sum() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "PE$3-TIME: $2" | awk '
        { sum += $4 } END { printf("TIME: 0000 : %u\n", sum) }
    '
}
total() {
    ./tools/m3-bench.sh time $2 $mhz 1 $3 < $1
}
lx_total() {
    total $1/gem5.log 1234
}
m3_total() {
    total $1/times.log 0001
}
stddev() {
    ./tools/m3-bench.sh stddev $2 $mhz 1 $3 < $1
}
xfer() {
    for f in $1/gem5-*; do
        sum $f aaaa $2
    done
}
m3_xfer() {
    # count transfers on m3fs and benchmark PE
    m3fs=$(xfer $1 1 | ./tools/m3-avg.awk)
    app=$(xfer $1 2 | ./tools/m3-avg.awk)
    echo $(($m3fs + $app))
}

gen_read() {
    lxdir=$1/lx-fs-read
    m3dir=$1/m3-fs-read-$2-$m3bpe

    lxto=`lx_total $lxdir`
    lxxf=`xfer $lxdir 0 | ./tools/m3-avg.awk`
    m3to=`m3_total $m3dir`
    m3xf=`m3_xfer $m3dir`

    echo "Lx M3"
    echo "$lxxf $m3xf"
    echo "$(($lxto - $lxxf)) $(($m3to - $m3xf))"
}

gen_write() {
    lxdir=$1/lx-fs-write
    m3dirwr=$1/m3-fs-write-$2-$m3bpe
    m3dircl=$1/m3-fs-write-clear-$2-$m3bpe

    lxto=`lx_total $lxdir`
    lxxf=`xfer $lxdir 0 | ./tools/m3-avg.awk`

    m3to=`m3_total $m3dirwr`
    m3xf=`m3_xfer $m3dirwr`
    m3clto=`m3_total $m3dircl`
    m3clxf=`m3_xfer $m3dircl`

    echo "Lx M3 M3Clear"
    echo "$lxxf $m3xf $m3clxf"
    echo "$(($lxto - $lxxf)) $(($m3to - $m3xf)) $(($m3clto - $m3clxf))"
}

gen_copy() {
    lxdircp=$1/lx-fs-copy
    lxdirsf=$1/lx-fs-sendfile
    m3dir=$1/m3-fs-copy-$2-$m3bpe

    lxto=`lx_total $lxdircp`
    lxxf=`xfer $lxdircp 0 | ./tools/m3-avg.awk`
    lxsfto=`lx_total $lxdirsf`
    lxsfxf=`xfer $lxdirsf 0 | ./tools/m3-avg.awk`

    m3to=`m3_total $m3dir`
    m3xf=`m3_xfer $m3dir`

    echo "Lx M3 LxSendFile"
    echo "$lxxf $m3xf $lxsfxf"
    echo "$(($lxto - $lxxf)) $(($m3to - $m3xf)) $(($lxsfto - $lxsfxf))"
}

gen_read_var() {
    lxto=`stddev $1/lx-fs-read/gem5.log 1234`
    m3to=`stddev $1/m3-fs-read-$2-$m3bpe/times.log 0001`

    echo "$lxto $m3to"
}

gen_write_var() {
    lxto=`stddev $1/lx-fs-write/gem5.log 1234`
    m3wr=`stddev $1/m3-fs-write-$2-$m3bpe/times.log 0001`
    m3cl=`stddev $1/m3-fs-write-clear-$2-$m3bpe/times.log 0001`

    echo "$lxto $m3wr $m3cl"
}

gen_copy_var() {
    lxcp=`stddev $1/lx-fs-copy/gem5.log 1234`
    lxsf=`stddev $1/lx-fs-sendfile/gem5.log 1234`
    m3to=`stddev $1/m3-fs-copy-$2-$m3bpe/times.log 0001`

    echo "$lxcp $m3to $lxsf"
}

for pe in a b c; do
    for b in read write write-notrunc copy sendfile; do
        echo "Splitting Linux-$b results..."
        csplit -s --prefix="$1/lx-fs-$b/gem5-" $1/lx-fs-$b/gem5.log "/DEBUG 0x1ff21234/+1" "{*}"
        rm $1/lx-fs-$b/gem5-{00,05}
    done

    for b in read write write-clear copy; do
        echo "Splitting M3-$b-$pe results..."
        grep "DEBUG 0x" $1/m3-fs-$b-$pe-$m3bpe/gem5.log > $1/m3-fs-$b-$pe-$m3bpe/times.log
        csplit -s --prefix="$1/m3-fs-$b-$pe-$m3bpe/gem5-" $1/m3-fs-$b-$pe-$m3bpe/times.log "/DEBUG 0x1ff20001/+1" "{*}"
        rm $1/m3-fs-$b-$pe-$m3bpe/gem5-{00,05}
    done

    echo "Generating data files for $pe..."
    gen_read $1 $pe > $1/fs-$pe-read.dat
    gen_write $1 $pe > $1/fs-$pe-write.dat
    gen_copy $1 $pe > $1/fs-$pe-copy.dat

    echo "Generating stddev files for $pe..."
    gen_read_var $1 $pe > $1/fs-$pe-read-stddev.dat
    gen_write_var $1 $pe > $1/fs-$pe-write-stddev.dat
    gen_copy_var $1 $pe > $1/fs-$pe-copy-stddev.dat
done

rel_diff() {
    diff=$(($1 < $2 ? $2 - $1 : $1 - $2))
    echo "scale=4;$diff / $1" | bc
}

echo "read : $(rel_diff $(m3_total $1/m3-fs-read-a-$m3bpe) $(m3_total $1/m3-fs-read-c-$m3bpe))" > $1/fs-diff.txt
echo "write: $(rel_diff $(m3_total $1/m3-fs-write-a-$m3bpe) $(m3_total $1/m3-fs-write-c-$m3bpe))" >> $1/fs-diff.txt
echo "copy : $(rel_diff $(m3_total $1/m3-fs-copy-a-$m3bpe) $(m3_total $1/m3-fs-copy-c-$m3bpe))" >> $1/fs-diff.txt
