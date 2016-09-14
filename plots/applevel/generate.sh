#!/bin/bash

osname="M3"
if [ "$BLIND" != "" ]; then
    suffix="-blind"
fi

source tools/linux.sh
source tools/plot_gen.sh

gen_pipetr  $1              | cut -d ' ' -f 1-2 > $1/applevel-pipetr-times.dat
gen_fstrace $1 "tar"        | cut -d ' ' -f 1-2 > $1/applevel-tar-times.dat
gen_fstrace $1 "untar"      | cut -d ' ' -f 1-2 > $1/applevel-untar-times.dat
gen_fstrace $1 "find"       | cut -d ' ' -f 1-2 > $1/applevel-find-times.dat
gen_fstrace $1 "sqlite"     | cut -d ' ' -f 1-2 > $1/applevel-sqlite-times.dat

Rscript plots/applevel/plot.R $1/applevel$suffix.pdf $osname \
    $1/applevel-pipetr-times.dat \
    $1/applevel-tar-times.dat \
    $1/applevel-untar-times.dat \
    $1/applevel-find-times.dat \
    $1/applevel-sqlite-times.dat
