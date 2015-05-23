#!/bin/sh

read_avgs=$1/fs-read-times.dat
read_stddev=$1/fs-read-stddevs.dat
chksum_avgs=$1/fs-chksum-times.dat
chksum_stddev=$1/fs-chksum-stddevs.dat
write_avgs=$1/fs-write-times.dat
write_stddev=$1/fs-write-stddevs.dat
copy_avgs=$1/fs-copy-times.dat
copy_stddev=$1/fs-copy-stddevs.dat

source tools/linux.sh

echo "M3 Lx Lxnc" > $read_avgs
echo "M3 Lx Lxnc" > $chksum_avgs
echo "M3 Lx Lxnc" > $write_avgs
echo "M3 Lx Lxnc" > $copy_avgs

m3trans=$((2048 * 1024 / 8))

m3read=350000
echo $((m3read - $m3trans)) `lx_rem_time $1 IDX_READ IDX_READ_MEMCPY` >> $read_avgs
echo $m3trans `lx_copy_time $1 IDX_READ IDX_READ_MEMCPY` >> $read_avgs
echo 0 0 0 >> $read_avgs

m3chksum=3505641
echo $((m3chksum - $m3trans)) `lx_copy_time $1 IDX_CHKSUM_MMAP IDX_CHKSUM_MMAP_AGAIN` >> $chksum_avgs
echo $m3trans 0 0 >> $chksum_avgs
echo 0 `lx_rem_time $1 IDX_CHKSUM_MMAP IDX_CHKSUM_MMAP_AGAIN` >> $chksum_avgs

m3write=550834
echo $((m3write - $m3trans)) `lx_rem_time $1 IDX_WRITE IDX_WRITE_MEMCPY` >> $write_avgs
echo $m3trans `lx_copy_time $1 IDX_WRITE IDX_WRITE_MEMCPY` >> $write_avgs
echo 0 0 0 >> $write_avgs

m3copy=914064
echo $((m3copy - $m3trans * 2)) 0 0 >> $copy_avgs
echo $(($m3trans * 2)) `lx_copy_time $1 IDX_COPY_MMAP IDX_COPY_MMAP_AGAIN` >> $copy_avgs
echo 0 `lx_rem_time $1 IDX_COPY_MMAP IDX_COPY_MMAP_AGAIN` >> $copy_avgs

echo "" > $read_stddev
echo "" > $chksum_stddev
echo "" > $write_stddev
echo "" > $copy_stddev

cat $read_avgs
cat $chksum_avgs
cat $write_avgs
cat $copy_avgs

Rscript plots/fs/plot.R $1/fs.pdf \
    $read_avgs $read_stddev \
    $chksum_avgs $chksum_stddev \
    $write_avgs $write_stddev \
    $copy_avgs $copy_stddev
