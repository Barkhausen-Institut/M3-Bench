#!/bin/zsh

for ts in 500 1000 2000; do
    for u in 2 4 8; do
        for ps in 32 64 128 256 512; do
            start=`grep -m 1 "DEBUG.*0x1ff11234" $1/m3-lte-$ts-$u-$ps/gem5.log | cut -d ':' -f 1`
            end=`grep "DEBUG.*0x1ff21234" $1/m3-lte-$ts-$u-$ps/gem5.log | tail -n 1 | cut -d ':' -f 1`
            if [ "$start" != "" ] && [ "$end" != "" ]; then
                echo $ts-$u-$ps "->" $((($end - $start) / 1000000))
            else
                echo $ts-$u-$ps "-> ???"
            fi
        done
    done
done
