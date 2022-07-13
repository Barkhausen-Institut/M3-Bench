#!/bin/bash

. tools/helper.sh

rscript_crop plots/rtas23-membw/plot.R "$1/eval-membw.pdf" \
    "$1/membw-16K.dat" \
    "$1/membw-32K.dat" \
    "$1/membw-64K.dat" \
    "$1/membw-128K.dat" \
    "$1/membw-256K.dat" \
    "$1/membw-512K.dat" \
    "$1/membw-1024K.dat" \
    "$1/membw-0.dat"
