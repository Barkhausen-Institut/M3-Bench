#!/bin/bash

for c in a-dram b-dram c-dram; do
    Rscript plots/diss-pipe/plot-cmp.R $1/eval-pipe-$c.pdf $1/pipe-$c.dat $1/pipe-$c-stddev.dat
done
Rscript plots/diss-pipe/plot-spm.R $1/eval-pipe-a-near-spm.pdf $1/pipe-a-near-spm.dat $1/pipe-a-near-spm-stddev.dat
