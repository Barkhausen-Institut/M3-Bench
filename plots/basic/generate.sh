#!/bin/sh

avgs=$1/basic-times.dat
stddev=$1/basic-stddevs.dat

lx_avg() {
    grep "$2" $1 | cut -d ':' -f 2 | awk '{ printf "%d", $1 }'
}

lx_stddev() {
    # tr to remove the \r
    grep "$2" $1 | cut -d ':' -f 2 | sed -e 's/[^\(]*(\([[:digit:]]*\))/\1/' | tr -d '[[:space:]]'
}

cache_misses() {
    # we have run it once with 13 cycles for M and once with 30 cycles.
    # thus, the equations are:
    # $ai = 1 * C + 13 * n
    # $bi = 1 * C + 30 * n
    # the right side is the matrix [1, 13; 1, 30].
    # we solve it by dividing it by [$ai; $bi] and take the second element to get C (opposite order)

    val=`octave -q --eval "A = [1, 13; 1, 30]; b = [$1; $2]; x = A \ b; round(nth_element(x, 2))" | awk '{ print $3 }'`
    if [ $val -lt $2 ]; then
        echo $(($2 - $val))
    else
        echo 0
    fi
}

lx_times() {
    lx30=`lx_avg $1/lx-30cycles.txt "$2"`
    lx13=`lx_avg $1/lx-13cycles.txt "$2"`
    cm=`cache_misses $lx13 $lx30`
    echo $(($lx30 - $cm)) $cm
}

# -- averages --
echo "M3 Linux LinuxCM" > $avgs

# syscall
echo -n "`./tools/m3-avg.awk < $1/m3-syscall.txt`" >> $avgs
echo `lx_times $1 "Time per syscall"` >> $avgs

# pthread
m3run=`./tools/m3-avg.awk < $1/m3-vpes.txt | awk '{ print $1 + $2 }'`
echo $m3run `lx_times $1 "Cycles per pthread_start"` >> $avgs

# clone
echo $m3run `lx_times $1 "Cycles per clone"` >> $avgs

# fork
echo $m3run `lx_times $1 "Cycles per fork "` >> $avgs

# exec
m3exec=`./tools/m3-avg.awk < $1/m3-vpes.txt | awk '{ print $1 + $4 }'`
echo $m3exec `lx_times $1 "Cycles per fork+exec"` >> $avgs

# vfork
echo $m3exec `lx_times $1 "Cycles per vfork+exec"` >> $avgs
echo >> $avgs


# -- std deviation --
echo "Syscall Thread Exec" > $stddev

# row 1 (m3 syscall, m3 run, m3 exec)
echo "`./tools/m3-stddev.awk < $1/m3-syscall.txt | tr -d '[[:space:]]'`" \
    "`grep 0001 $1/m3-vpes.txt | ./tools/m3-stddev.awk | tr -d '[[:space:]]'`" \
    "`grep 0003 $1/m3-vpes.txt | ./tools/m3-stddev.awk | tr -d '[[:space:]]'`" >> $stddev

# row 2 (lx syscall, lx pthread, lx exec)
echo "`lx_stddev $1/lx-30cycles.txt 'Time per syscall'`" \
    "`lx_stddev $1/lx-30cycles.txt 'Cycles per pthread_start'`" \
    "`lx_stddev $1/lx-30cycles.txt 'Cycles per fork+exec'`" >> $stddev

# row 3 (0, lx clone, lx vfork)
echo 0 \
    `lx_stddev $1/lx-30cycles.txt "Cycles per clone"` \
    `lx_stddev $1/lx-30cycles.txt "Cycles per vfork+exec"` >> $stddev

# row 4 (0, lx fork, 0)
echo 0 \
    `lx_stddev $1/lx-30cycles.txt "Cycles per fork "` \
    0 >> $stddev
echo >> $stddev

Rscript plots/basic/plot.R $avgs $stddev $1/basic.pdf
