#!/bin/bash

get_m3_xfertime() {
    grep 'TIME: aaaa' $1 | awk '{ sum += $4 } END { print sum }'
}

if [ "$BLIND" != "" ]; then
    osname="XY"
    suffix="-blind"
else
    osname="M3"
fi

read_avgs=$1/fs-read-times.dat
read_stddev=$1/fs-read-stddevs.dat
write_avgs=$1/fs-write-times.dat
write_stddev=$1/fs-write-stddevs.dat
copy_avgs=$1/fs-copy-times.dat
copy_stddev=$1/fs-copy-stddevs.dat
pipe_avgs=$1/fs-pipe-times.dat
pipe_stddev=$1/fs-pipe-stddevs.dat

source tools/linux.sh

echo "M3 Lx Lxnc" > $read_avgs
echo "M3 Lx Lxnc" > $write_avgs
echo "M3 Lx Lxnc" > $copy_avgs
echo "M3 Lx Lxnc" > $pipe_avgs

m3trans=`get_m3_xfertime $1/m3-fsread.txt`
m3read=`grep 0001 $1/m3-fsread.txt | ./tools/m3-avg.awk`
echo $((m3read - $m3trans)) `lx_rem_time $1/lx IDX_READ IDX_READ_MEMCPY` >> $read_avgs
echo $m3trans `lx_copy_time $1/lx IDX_READ_MEMCPY` >> $read_avgs
echo 0 0 0 >> $read_avgs

m3trans=`get_m3_xfertime $1/m3-fswrite.txt`
m3write=`grep 0001 $1/m3-fswrite.txt | ./tools/m3-avg.awk`
echo $((m3write - $m3trans)) `lx_rem_time $1/lx IDX_WRITE IDX_WRITE_MEMCPY` >> $write_avgs
echo $m3trans `lx_copy_time $1/lx IDX_WRITE_MEMCPY` >> $write_avgs
echo 0 0 0 >> $write_avgs

m3trans=`get_m3_xfertime $1/m3-fscopy.txt`
m3copy=`grep 0001 $1/m3-fscopy.txt | ./tools/m3-avg.awk`
echo $m3copy $m3trans
echo $((m3copy - $m3trans)) 0 0 >> $copy_avgs
echo $(($m3trans)) `lx_copy_time $1/lx IDX_COPY_MMAP_AGAIN` >> $copy_avgs
echo 0 `lx_rem_time $1/lx IDX_COPY_MMAP IDX_COPY_MMAP_AGAIN` >> $copy_avgs

m3trans=`get_m3_xfertime $1/m3-pipe-indirect.txt`
m3pipe=`grep 0000 $1/m3-pipe-indirect.txt | ./tools/m3-avg.awk`
echo $((m3pipe - $m3trans)) `lx_rem_time $1/lx IDX_PIPE IDX_PIPE_MEMCPY` >> $pipe_avgs
echo $(($m3trans)) `lx_copy_time $1/lx IDX_PIPE_MEMCPY` >> $pipe_avgs
echo 0 0 0 >> $pipe_avgs

echo 0 \
    "`lx_stddev $1/lx-30cycles.txt IDX_READ`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_READ`" > $read_stddev

echo 0 \
    "`lx_stddev $1/lx-30cycles.txt IDX_WRITE`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_WRITE`" > $write_stddev

echo 0 \
    "`lx_stddev $1/lx-30cycles.txt IDX_COPY_MMAP`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_COPY_MMAP`" > $copy_stddev

echo 0 \
    "`lx_stddev $1/lx-30cycles.txt IDX_PIPE`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_PIPE`" > $pipe_stddev

Rscript plots/fs/plot.R $1/fs$suffix.pdf $osname \
    $read_avgs $read_stddev \
    $write_avgs $write_stddev \
    $copy_avgs $copy_stddev \
    $pipe_avgs $pipe_stddev
