#!/bin/bash

osname="M3"
if [ "$BLIND" != "" ]; then
    suffix="-blind"
fi

source tools/linux.sh
source tools/plot_gen.sh

gen_fstrace $1 "tar"        > $1/applevel-tar-times.dat
gen_fstrace $1 "untar"      > $1/applevel-untar-times.dat
gen_fstrace $1 "find"       > $1/applevel-find-times.dat
gen_fstrace $1 "sqlite"     > $1/applevel-sqlite-times.dat

Rscript plots/applevel_orch/plot.R $1/applevel_orch$suffix.pdf $osname \
    $1/applevel-tar-times.dat \
    $1/applevel-untar-times.dat \
    $1/applevel-find-times.dat \
    $1/applevel-sqlite-times.dat
