#!/bin/sh

. tools/helper.sh

rscript_crop plots/asplos22-ycsb/plot.R $1/eval-ycsb.pdf \
    $1/ycsb-read-times.dat $1/ycsb-read-stddev.dat \
    $1/ycsb-insert-times.dat $1/ycsb-insert-stddev.dat \
    $1/ycsb-update-times.dat $1/ycsb-update-stddev.dat \
    $1/ycsb-mixed-times.dat $1/ycsb-mixed-stddev.dat \
    $1/ycsb-scan-times.dat $1/ycsb-scan-stddev.dat
