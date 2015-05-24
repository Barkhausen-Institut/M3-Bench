#!/bin/bash

sctimes=$1/sysc-times.dat
thtimes=$1/thread-times.dat
extimes=$1/exec-times.dat

scstddev=$1/sysc-stddev.dat
thstddev=$1/thread-stddev.dat
exstddev=$1/exec-stddev.dat

avgs=$1/basic-times.dat
stddev=$1/basic-stddevs.dat

source tools/linux.sh

# syscall
echo "M3 Linux" > $sctimes
echo "`./tools/m3-avg.awk < $1/m3-syscall.txt | tr -d '[[:space:]]'`" \
    "`lx_base_time $1 IDX_SYSCALL`" >> $sctimes
echo 0 \
    "`lx_cachemiss_time $1 IDX_SYSCALL`" >> $sctimes

echo "`./tools/m3-stddev.awk < $1/m3-syscall.txt | tr -d '[[:space:]]'`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_SYSCALL`" > $scstddev

# thread
echo "M3-run clone fork" > $thtimes
echo "`./tools/m3-avg.awk < $1/m3-vpes.txt | awk '{ print $1 + $2 }'`" \
    "`lx_base_time $1 IDX_CLONE`" \
    "`lx_base_time $1 IDX_FORK`" >> $thtimes
echo 0 \
    "`lx_cachemiss_time $1 IDX_CLONE`" \
    "`lx_cachemiss_time $1 IDX_FORK`" >> $thtimes

echo "`grep 0001 $1/m3-vpes.txt | ./tools/m3-stddev.awk | tr -d '[[:space:]]'`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_CLONE`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_FORK`" > $thstddev

# exec
echo "M3-exec exec vfork" > $extimes
echo "`./tools/m3-avg.awk < $1/m3-vpes.txt | awk '{ print $1 + $4 }'`" \
    "`lx_base_time $1 IDX_EXEC`" \
    "`lx_base_time $1 IDX_VEXEC`" >> $extimes
echo 0 \
    "`lx_cachemiss_time $1 IDX_EXEC`" \
    "`lx_cachemiss_time $1 IDX_VEXEC`" >> $extimes

echo "`grep 0003 $1/m3-vpes.txt | ./tools/m3-stddev.awk | tr -d '[[:space:]]'`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_EXEC`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_VEXEC`" > $exstddev

Rscript plots/basic/plot.R $1/basic.pdf \
    $sctimes $scstddev \
    $thtimes $thstddev \
    $extimes $exstddev
