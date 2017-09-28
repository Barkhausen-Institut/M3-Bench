#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-fs-read-spm/output.txt`

lx_total() {
    cut -d ' ' -f 1 $1/lx-fs-$2/res.txt
}
lx_xfer() {
    cut -d ' ' -f 2 $1/lx-fs-$2/res.txt
}

m3_sum() {
    ./m3/src/tools/bench.sh $1 $mhz | grep "TIME: $2" | awk '{ sum += $4 } END { printf("%u\n", sum) }'
}
m3_total() {
    ./tools/m3-bench.sh time 0001 $mhz 0 < $1/m3-fs-$2-$3/gem5.log
}
m3_xfer() {
    m3_sum $1/m3-fs-$2-$3/gem5.log aaaa
}

gen_read() {
    lxto=`lx_total $1 read`
    lxxf=`lx_xfer $1 read`
    m3to=`m3_total $1 read $2`
    m3xf=`m3_xfer $1 read $2`

    echo "Lx M3"
    echo "$lxxf $m3xf"
    echo "$(($lxto - $lxxf)) $(($m3to - $m3xf))"
}

gen_write() {
    lxto=`lx_total $1 write`
    lxxf=`lx_xfer $1 write`
    lxtrto=`lx_total $1 write-notrunc`
    lxtrxf=`lx_xfer $1 write-notrunc`

    m3to=`m3_total $1 write $2`
    m3xf=`m3_xfer $1 write $2`
    m3clto=`m3_total $1 write-clear $2`
    m3clxf=`m3_xfer $1 write-clear $2`

    echo "Lx LxNoTrunc M3 M3Clear"
    echo "$lxxf $m3xf $lxtrto $m3clxf"
    echo "$(($lxto - $lxxf)) $(($m3to - $m3xf)) $(($lxtrto - $lxtrxf)) $(($m3clto - $m3clxf))"
}

gen_copy() {
    lxto=`lx_total $1 copy`
    lxxf=`lx_xfer $1 copy`
    lxsfto=`lx_total $1 sendfile`
    lxsfxf=`lx_xfer $1 sendfile`

    m3to=`m3_total $1 copy $2`
    m3xf=`m3_xfer $1 copy $2`

    echo "Lx LxSendFile M3"
    echo "$lxxf $m3xf $lxsfxf"
    echo "$(($lxto - $lxxf)) $(($m3to - $m3xf)) $(($lxsfto - $lxsfxf))"
}

for c in spm caches; do
    gen_read $1 $c > $1/fs-$c-read.dat
    gen_write $1 $c > $1/fs-$c-write.dat
    gen_copy $1 $c > $1/fs-$c-copy.dat

    Rscript plots/diss-fs/plot.R $1/fs-$c.pdf \
        $1/fs-$c-read.dat \
        $1/fs-$c-write.dat \
        $1/fs-$c-copy.dat
done
