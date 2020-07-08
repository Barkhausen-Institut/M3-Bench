#!/bin/zsh

mhz=3000
isa=riscv

get_lx_total() {
    tail -n +2 $1/eval-app-$2-times.dat | awk '{ sum += $1 } END { print(sum) }'
}
get_m3ex_total() {
    tail -n +2 $1/eval-app-$2-times.dat | awk '{ sum += $2 } END { print(sum) }'
}
get_m3sh_total() {
    comp=$(tail -n -1 $1/eval-app-$2-times.dat | awk '{ sum += $1 } END { print(sum) }')
    os=$(zcat $1/m3-tests-$2-sh-$isa-64/gem5.log.gz | ./m3/src/tools/bench.sh $mhz \
        | grep "TIME: 0000" | tail -n 3 | ./tools/m3-avg.awk)
    echo $(($comp + $os))
}

echo "m3ex" "m3sh" "lx" > $1/eval-app-ctx.dat
for tr in tar untar sha256sum sort find sqlite leveldb; do
    echo "Calculating time for $tr..."
    m3ex=`get_m3ex_total $1 $tr`
    m3sh=`get_m3sh_total $1 $tr`
    lx=`get_lx_total $1 $tr`
    echo $tr: $m3ex $m3sh $lx
    echo 1 $(((1. * $m3sh) / $m3ex)) $(((1. * $lx) / $m3ex)) >> $1/eval-app-ctx.dat
done
