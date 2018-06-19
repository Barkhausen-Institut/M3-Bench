#!/bin/sh

Rscript plots/diss-syscall/plot.R $1/eval-syscall.pdf $1/syscall-times.dat $1/syscall-stddev.dat
