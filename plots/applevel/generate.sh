#!/bin/bash

get_m3_waittime() {
    grep 'TIME: aaaa' $1 | awk '{ sum += $4 } END { print sum }'
}

osname="M3"
if [ "$BLIND" != "" ]; then
    suffix="-blind"
fi

pipetr_avgs=$1/applevel-pipetr-times.dat
tar_avgs=$1/applevel-tar-times.dat
untar_avgs=$1/applevel-untar-times.dat
find_avgs=$1/applevel-find-times.dat
sqlite_avgs=$1/applevel-sqlite-times.dat

source tools/linux.sh

echo "M3 Lx Lxnc" > $pipetr_avgs
echo "M3 Lx Lxnc" > $tar_avgs
echo "M3 Lx Lxnc" > $untar_avgs
echo "M3 Lx Lxnc" > $find_avgs
echo "M3 Lx Lxnc" > $sqlite_avgs

# size of the file we read
m3pipetrtrans=$((4 * 64 * 1024 / 8))
# size of the tar file we create/extract; 2* because we need to read that amount and write it, too
m3tartrans=$((2 * 1216000 / 8))
m3sqlitetrans=$((57704 / 8))

m3pipetr=`grep 0000 $1/m3-pipetr-1.cfg-result.txt | ./tools/m3-avg.awk`
m3wait=`get_m3_waittime $1/m3-pipetr-1.cfg-result.txt`
echo $(($m3pipetr - $m3pipetrtrans - $m3wait)) `lx_pipetr_total $1/lx` >> $pipetr_avgs
echo $m3pipetrtrans `lx_copy_time $1/lx IDX_PIPETR_MEMCPY` >> $pipetr_avgs
echo $m3wait `lx_copy_time $1/lx IDX_PIPETR_APP` >> $pipetr_avgs

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

m3sqlite=`grep 0000 $1/m3-fstrace.sqlite-txt | ./tools/m3-avg.awk`
m3wait=`get_m3_waittime $1/m3-fstrace.sqlite-txt`
echo $(($m3sqlite - $m3sqlitetrans - $m3wait)) `lx_fstrace_total $1/lx-fstrace-sqlite-result` >> $sqlite_avgs
echo $(($m3sqlitetrans)) `lx_copy_time $1/lx-fstrace-sqlite-result IDX_FSTRACE_MEMCPY` >> $sqlite_avgs
echo $m3wait `lx_copy_time $1/lx-fstrace-sqlite-result IDX_FSTRACE_WAIT` >> $sqlite_avgs

lxtar=`lx_avg $1/lx-fstrace-tar-result-30cycles.txt "IDX_FSTRACE_TOTAL"`
lxuntar=`lx_avg $1/lx-fstrace-untar-result-30cycles.txt "IDX_FSTRACE_TOTAL"`

eq=`printf 'printf("%%f",100 / (%f / %f));' $lxtar $m3tar`
echo $m3tar $lxtar "->" $(php -r "$eq") "%" > $1/applevel-lxm3.dat
eq=`printf 'printf("%%f",100 / (%f / %f));' $lxuntar $m3untar`
echo $m3untar $lxuntar "->" $(php -r "$eq") "%" >> $1/applevel-lxm3.dat

Rscript plots/applevel/plot.R $1/applevel$suffix.pdf $osname \
    $pipetr_avgs \
    $tar_avgs \
    $untar_avgs \
    $find_avgs \
    $sqlite_avgs
