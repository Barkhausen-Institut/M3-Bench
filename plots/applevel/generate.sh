#!/bin/bash

. tools/fstrace-helper.sh

gen_results $1 "tar"    tar-0-0    > $1/applevel-tar-times.dat
gen_results $1 "untar"  untar-0-0  > $1/applevel-untar-times.dat
gen_results $1 "find"   find-0-0   > $1/applevel-find-times.dat
gen_results $1 "sqlite" sqlite-0-0 > $1/applevel-sqlite-times.dat

Rscript plots/applevel/plot.R $1/applevel.pdf \
    $1/applevel-tar-times.dat \
    $1/applevel-untar-times.dat \
    $1/applevel-find-times.dat \
    $1/applevel-sqlite-times.dat
