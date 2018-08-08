#!/bin/zsh

. tools/helper.sh

rscript_crop plots/asplos19-app/plot.R $1/eval-app.pdf --clip -2 \
    $1/eval-app-tar-times.dat \
    $1/eval-app-untar-times.dat \
    $1/eval-app-sha256sum-times.dat \
    $1/eval-app-sort-times.dat \
    $1/eval-app-find-times.dat \
    $1/eval-app-sqlite-times.dat \
    $1/eval-app-leveldb-times.dat
