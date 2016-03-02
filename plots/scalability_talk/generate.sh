#!/bin/bash

get_values() {
    if [ "$2" = "pipetr" ]; then
        echo -n "a "
    fi
    for i in 1 2 4 8 16; do
        val=`grep "TIME: 0000 :" $1/scale-$2-$i.cfg-result.txt | ./tools/m3-avg.awk`
        echo -n $val " "
    done
}

pipetr=$1/m3-scale_talk-pipetr.dat
tar_avgs=$1/m3-scale_talk-tar.dat
untar_avgs=$1/m3-scale_talk-untar.dat
find_avgs=$1/m3-scale_talk-find.dat
sqlite_avgs=$1/m3-scale_talk-sqlite.dat

get_values $1 pipetr | xargs > $pipetr
get_values $1 tar | xargs > $tar_avgs
get_values $1 untar | xargs > $untar_avgs
get_values $1 find | xargs > $find_avgs
get_values $1 sqlite | xargs > $sqlite_avgs

Rscript plots/scalability_talk/plot.R $1/scale_talk.pdf $pipetr $tar_avgs $untar_avgs $find_avgs $sqlite_avgs
