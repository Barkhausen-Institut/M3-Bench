#!/bin/zsh

. tools/helper.sh

rscript_crop plots/diss-app-scale/plot.R $1/eval-app-scale-all.pdf \
    $1/app-scale-tar.dat \
    $1/app-scale-untar.dat \
    $1/app-scale-sha256sum.dat \
    $1/app-scale-find.dat \
    $1/app-scale-sqlite.dat \
    $1/app-scale-leveldb.dat \
    $1/app-scale-sort.dat
