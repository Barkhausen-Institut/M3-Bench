#!/bin/sh

get_m3_xfertime() {
    grep 'TIME: aaaa' $1 | awk '{ sum += $4 } END { print sum }'
}

get_m3_waittime() {
    grep 'TIME: bbbb' $1 | awk '{ sum += $4 } END { print sum }'
}

gen_pipetr() {
    m3trans=`get_m3_xfertime $1/m3-pipetr.txt`
    m3pipetr=`grep 'TIME: 0000' $1/m3-pipetr.txt | ./tools/m3-avg.awk`
    m3wait=`get_m3_waittime $1/m3-pipetr.txt`
    echo "M3 Lx Lxnc"
    echo $(($m3pipetr - $m3trans - $m3wait)) `lx_pipetr_total $1/lx`
    echo $m3trans `lx_copy_time $1/lx IDX_PIPETR_MEMCPY`
    echo $m3wait `lx_copy_time $1/lx IDX_PIPETR_APP`
}

gen_fstrace() {
    m3trans=`get_m3_xfertime $1/m3-fstrace.$2-txt`
    m3total=`grep 'TIME: 0000' $1/m3-fstrace.$2-txt | ./tools/m3-avg.awk`
    m3wait=`get_m3_waittime $1/m3-fstrace.$2-txt`
    echo "M3 Lx Lxnc"
    echo $(($m3total - $m3trans - $m3wait)) `lx_fstrace_total $1/lx-fstrace-$2-result`
    echo $(($m3trans)) `lx_copy_time $1/lx-fstrace-$2-result IDX_FSTRACE_MEMCPY`
    echo $m3wait `lx_copy_time $1/lx-fstrace-$2-result IDX_FSTRACE_WAIT`
}
