#!/bin/bash

get_m3_appavg() {
    if [ "`grep 'TIME: 1234' $1 | tail -n +2`" != "" ]; then
        grep 'TIME: 1234' $1 | tail -n +2 | ./tools/m3-avg.awk
    else
        echo 1
    fi
}
get_m3_appsd() {
    grep 'TIME: 1234' $1 | tail -n +2 | ./tools/m3-stddev.awk
}
get_name() {
    echo $1 | sed -e 's/m3fs-\(.*\)/\1-m3fs/'
}
get_ratio() {
    if [ "$2" = "" ]; then
        echo 0
    else
        echo "scale=8; ($1 * 1.0) / $2" | bc
    fi
}
get_pipe_runtime() {
    awk '
    /DEBUG.*1ff11234/ {
        p = 1
    }

    /pe04.dtu.connector: Waking up core/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            start = res[1]
        }
    }

    /pe04.dtu.connector: Suspending core/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            time += (res[1] - start) / 1000
        }
    }

    /DEBUG.*1ff21234/ {
        p = 0
        count += 1
    }

    END {
        print(time / count)
    }' $1
}

gen_data() {
    echo "ratio stddev"
    for s in 64k 128k 256k 512k 1024k; do
        echo $(get_ratio $(get_m3_appavg $1/m3-rctmux-$(get_name $2-$s)-alone.txt) $(get_m3_appavg $1/m3-rctmux-$(get_name $2-$s)-shared.txt)) 0
    done
}
gen_sd() {
    for s in 64k 128k 256k 512k 1024k; do
        ti=$(get_m3_appavg $1/m3-rctmux-$(get_name $3-$s)-$2.txt)
        sd=$(get_m3_appsd $1/m3-rctmux-$(get_name $3-$s)-$2.txt)
        echo $(get_name $3-$s) $sd $ti $(get_ratio $sd $ti)
    done
}
gen_pipe_time() {
    for s in 64k 128k 256k 512k 1024k; do
        ti=$(get_m3_appavg $1/m3-rctmux-$(get_name $2-$s)-alone.txt)
        rt=$(get_pipe_runtime $1/m3-rctmux-$(get_name $2-$s)-alone.log)
        echo $(get_name $2-$s) $rt $ti $(get_ratio $rt $ti)
    done
}

for a in rand-wc rand-sink cat-wc cat-sink cat-wc-m3fs; do
    gen_data $1 $a > $1/m3-rctmux-$a-times.dat
done

echo "name runtime percent" > $1/m3-rctmux-pipe-alone-pipeserv.dat
echo "name stddev runtime percent" > $1/m3-rctmux-pipe-alone-sd.dat
echo "name stddev runtime percent" > $1/m3-rctmux-pipe-shared-sd.dat
for a in rand-wc rand-sink cat-wc cat-sink cat-wc-m3fs; do
    gen_sd $1 alone $a >> $1/m3-rctmux-pipe-alone-sd.dat
    gen_sd $1 shared $a >> $1/m3-rctmux-pipe-shared-sd.dat
    # gen_pipe_time $1 $a >> $1/m3-rctmux-pipe-alone-pipeserv.dat
done

Rscript plots/rctmux-pipe/plot.R $1/m3-rctmux-pipe.pdf \
    $1/m3-rctmux-rand-wc-times.dat \
    $1/m3-rctmux-rand-sink-times.dat \
    $1/m3-rctmux-cat-wc-times.dat \
    $1/m3-rctmux-cat-sink-times.dat \
    $1/m3-rctmux-cat-wc-m3fs-times.dat
