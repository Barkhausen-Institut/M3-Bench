#!/bin/bash

get_m3_waittime() {
    grep 'TIME: aaaa' $1 | awk '{ sum += $4 } END { print sum }'
}

catwc_avgs=$1/applevel-catwc-times.dat
tar_avgs=$1/applevel-tar-times.dat
untar_avgs=$1/applevel-untar-times.dat
find_avgs=$1/applevel-find-times.dat

source tools/linux.sh

echo "M3 Lx Lxnc" > $catwc_avgs
echo "M3 Lx Lxnc" > $tar_avgs
echo "M3 Lx Lxnc" > $untar_avgs
echo "M3 Lx Lxnc" > $find_avgs

# size of the file we read
m3catwctrans=$((64 * 1024 / 8))
# size of the tar file we create/extract; 2* because we need to read that amount and write it, too
m3tartrans=$((2 * 1216000 / 8))

m3catwc=`grep 000a $1/m3-catwc.txt | ./tools/m3-avg.awk`
echo $(($m3catwc - $m3catwctrans)) `lx_rem_time $1/lx IDX_EXECPIPE IDX_EXECPIPE_MEMCPY` >> $catwc_avgs
echo $m3catwctrans `lx_copy_time $1/lx IDX_EXECPIPE_MEMCPY` >> $catwc_avgs
echo 0 0 0 >> $catwc_avgs

m3tar=`grep 0000 $1/m3-fstrace.tar-txt | ./tools/m3-avg.awk`
m3wait=`get_m3_waittime $1/m3-fstrace.tar-txt`
echo $(($m3tar - $m3tartrans - $m3wait)) `lx_fstrace_total $1/lx-fstrace-tar-result` >> $tar_avgs
echo $m3tartrans `lx_copy_time $1/lx-fstrace-tar-result IDX_FSTRACE_MEMCPY` >> $tar_avgs
echo $m3wait `lx_copy_time $1/lx-fstrace-tar-result IDX_FSTRACE_WAIT` >> $tar_avgs

m3untar=`grep 0000 $1/m3-fstrace.untar-txt | ./tools/m3-avg.awk`
m3wait=`get_m3_waittime $1/m3-fstrace.untar-txt`
echo $(($m3untar - $m3tartrans - $m3wait)) `lx_fstrace_total $1/lx-fstrace-untar-result` >> $untar_avgs
echo $(($m3tartrans)) `lx_copy_time $1/lx-fstrace-untar-result IDX_FSTRACE_MEMCPY` >> $untar_avgs
echo $m3wait `lx_copy_time $1/lx-fstrace-untar-result IDX_FSTRACE_WAIT` >> $untar_avgs

m3find=`grep 0000 $1/m3-fstrace.find-txt | ./tools/m3-avg.awk`
m3wait=`get_m3_waittime $1/m3-fstrace.find-txt`
echo $(($m3find - $m3wait)) `lx_fstrace_total $1/lx-fstrace-find-result` >> $find_avgs
echo 0 `lx_copy_time $1/lx-fstrace-find-result IDX_FSTRACE_MEMCPY` >> $find_avgs
echo $m3wait `lx_copy_time $1/lx-fstrace-find-result IDX_FSTRACE_WAIT` >> $find_avgs

Rscript plots/applevel/plot.R $1/applevel.pdf \
    $catwc_avgs \
    $tar_avgs \
    $untar_avgs \
    $find_avgs
