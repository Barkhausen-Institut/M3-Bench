#!/bin/sh

avgs=$1/basic-times.dat
stddev=$1/basic-stddevs.dat

source tools/linux.sh

# -- averages --
echo "M3 Linux LinuxCM" > $avgs

# syscall
echo -n "`./tools/m3-avg.awk < $1/m3-syscall.txt`" >> $avgs
echo `lx_times $1 IDX_SYSCALL` >> $avgs

# pthread
m3run=`./tools/m3-avg.awk < $1/m3-vpes.txt | awk '{ print $1 + $2 }'`
echo $m3run `lx_times $1 IDX_PTHREAD` >> $avgs

# clone
echo $m3run `lx_times $1 IDX_CLONE` >> $avgs

# fork
echo $m3run `lx_times $1 IDX_FORK` >> $avgs

# exec
m3exec=`./tools/m3-avg.awk < $1/m3-vpes.txt | awk '{ print $1 + $4 }'`
echo $m3exec `lx_times $1 IDX_EXEC` >> $avgs

# vfork
echo $m3exec `lx_times $1 IDX_VEXEC` >> $avgs
echo >> $avgs


# -- std deviation --
echo "Syscall Thread Exec" > $stddev

# row 1 (m3 syscall, m3 run, m3 exec)
echo "`./tools/m3-stddev.awk < $1/m3-syscall.txt | tr -d '[[:space:]]'`" \
    "`grep 0001 $1/m3-vpes.txt | ./tools/m3-stddev.awk | tr -d '[[:space:]]'`" \
    "`grep 0003 $1/m3-vpes.txt | ./tools/m3-stddev.awk | tr -d '[[:space:]]'`" >> $stddev

# row 2 (lx syscall, lx pthread, lx exec)
echo "`lx_stddev $1/lx-30cycles.txt IDX_SYSCALL`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_PTHREAD`" \
    "`lx_stddev $1/lx-30cycles.txt IDX_EXEC`" >> $stddev

# row 3 (0, lx clone, lx vfork)
echo 0 \
    `lx_stddev $1/lx-30cycles.txt IDX_CLONE` \
    `lx_stddev $1/lx-30cycles.txt IDX_VEXEC` >> $stddev

# row 4 (0, lx fork, 0)
echo 0 \
    `lx_stddev $1/lx-30cycles.txt IDX_FORK` \
    0 >> $stddev
echo >> $stddev

Rscript plots/basic/plot.R $avgs $stddev $1/basic.pdf
