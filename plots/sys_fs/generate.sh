#!/bin/bash

osname="A"
if [ "$BLIND" != "" ]; then
    suffix="-blind"
fi

sctimes=$1/sys_fs-sysc-times.dat
scstddev=$1/sys_fs-sysc-stddev.dat

read_avgs=$1/sys_fs-read-times.dat
read_stddev=$1/sys_fs-read-stddevs.dat
write_avgs=$1/sys_fs-write-times.dat
write_stddev=$1/sys_fs-write-stddevs.dat
pipe_avgs=$1/sys_fs-pipe-times.dat
pipe_stddev=$1/sys_fs-pipe-stddevs.dat

source tools/linux.sh

echo "M3 Lx Lxnc" > $sctimes
echo "M3 Lx Lxnc" > $read_avgs
echo "M3 Lx Lxnc" > $write_avgs
echo "M3 Lx Lxnc" > $pipe_avgs

# syscall
echo "`./tools/m3-avg.awk < $1/m3-syscall.txt | tr -d '[[:space:]]'`" \
    "`lx_avg $1/lx-30cycles.txt IDX_SYSCALL`" \
    "`lx_base_time $1/lx IDX_SYSCALL`" >> $sctimes
echo 0 0 0 >> $sctimes

echo "`./tools/m3-stddev.awk < $1/m3-syscall.txt | tr -d '[[:space:]]'`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_SYSCALL`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_SYSCALL`" > $scstddev

# fs
m3trans=$((2048 * 1024 / 8))

m3read=`grep 0001 $1/m3-fsread.txt | ./tools/m3-avg.awk`
echo $((m3read - $m3trans)) `lx_rem_time $1/lx IDX_READ IDX_READ_MEMCPY` >> $read_avgs
echo $m3trans `lx_copy_time $1/lx IDX_READ_MEMCPY` >> $read_avgs

m3write=`grep 0001 $1/m3-fswrite.txt | ./tools/m3-avg.awk`
echo $((m3write - $m3trans)) `lx_rem_time $1/lx IDX_WRITE IDX_WRITE_MEMCPY` >> $write_avgs
echo $m3trans `lx_copy_time $1/lx IDX_WRITE_MEMCPY` >> $write_avgs

m3pipe=`grep 0000 $1/m3-pipe.txt | ./tools/m3-avg.awk`
echo $((m3pipe - $m3trans * 2)) `lx_rem_time $1/lx IDX_PIPE IDX_PIPE_MEMCPY` >> $pipe_avgs
echo $(($m3trans * 2)) `lx_copy_time $1/lx IDX_PIPE_MEMCPY` >> $pipe_avgs

echo 0 \
    "`lx_stddev $1/lx-30cycles.txt IDX_READ`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_READ`" > $read_stddev

echo 0 \
    "`lx_stddev $1/lx-30cycles.txt IDX_WRITE`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_WRITE`" > $write_stddev

echo 0 \
    "`lx_stddev $1/lx-30cycles.txt IDX_PIPE`" \
    "`lx_stddev $1/lx-13cycles.txt IDX_PIPE`" > $pipe_stddev

Rscript plots/sys_fs/plot.R $1/sys_fs$suffix.pdf $osname \
    $sctimes $scstddev \
    $read_avgs $read_stddev \
    $write_avgs $write_stddev \
    $pipe_avgs $pipe_stddev
