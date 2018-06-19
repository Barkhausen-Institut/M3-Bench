#!/bin/zsh

. tools/helper.sh

for tr in nginx; do
    rscript_crop plots/diss-app-server/plot.R $1/eval-app-server-$tr.pdf $1/app-server-$tr.dat
done
