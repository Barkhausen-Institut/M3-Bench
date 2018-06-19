#!/bin/sh

echo "8 64 128 256 512" > $1/msgs.dat
echo "Core 3.35 3.35 3.02 2.6 1.85" >> $1/msgs.dat
echo "DTU 1.18 1.28 1.38 1.48 1.58" >> $1/msgs.dat

Rscript plots/diss-power-msgs/plot.R $1/eval-power-msgs.pdf $1/msgs.dat
