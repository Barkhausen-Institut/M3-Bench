#!/bin/sh

. tools/helper.sh

avg_time() {
    awk '{
        vals[$1][count[$1]] = $2
        total[$1] += $2
        count[$1] += 1
    }

    END {
        for(len in total);
        for(i in total) {
            printf "%d", total[i] / count[i]
            if(i + 1 < len)
                printf(" ")
        }
        printf "\n"
    }'
}

stddev_time() {
    awk '
    function stddev(vals, avg) {
        sum = 0
        for(v in vals) {
            sum += (vals[v] - avg) * (vals[v] - avg)
        }
        return sqrt(sum / length(vals))
    }

    {
        vals[$1][count[$1]] = $2
        total[$1] += $2
        count[$1] += 1
    }

    END {
        for(i in vals) {
            printf "%d ", stddev(vals[i], total[i] / count[i])
        }
        printf "\n"
    }'
}

extract_m3_time() {
    grep $2 $1/m3-ycsb-$3/output.txt | tail -n 8 | avg_time
}
extract_m3_stddev() {
    grep $2 $1/m3-ycsb-$3/output.txt | tail -n 8 | stddev_time
}

extract_lx_time() {
    grep $2 $1/lx-ycsb-$3/res.txt | tail -n 8 | avg_time
}
extract_lx_stddev() {
    grep $2 $1/lx-ycsb-$3/res.txt | tail -n 8 | stddev_time
}

extract_vpe_time() {
    grep "Destroyed VPE $2" $1 | \
        sed -e 's/\x1b\[0m//g' | \
        sed -re 's/.*VPE [0-9]* \(([0-9]*)ns.*/\1/'
}

for wl in read update insert scan mixed; do
    m3exsys=$(extract_m3_time $1 "Systemtime:" $wl-iso)
    m3extot=$(extract_m3_time $1 "Totaltime:" $wl-iso)
    m3shsys=$(extract_m3_time $1 "Systemtime:" $wl-sh)
    m3shtot=$(extract_m3_time $1 "Totaltime:" $wl-sh)
    lxusr=$(extract_lx_time $1 "Usertime:" $wl)
    lxtot=$(extract_lx_time $1 "Totaltime:" $wl)
    lxsys=$(($lxtot - $lxusr))
    echo "M3iso M3sh Lx" > $1/ycsb-$wl-times.dat
    echo $(($m3extot - $m3exsys)) $(($m3shtot - $m3shsys)) $lxusr >> $1/ycsb-$wl-times.dat
    echo $m3exsys $m3shsys $lxsys >> $1/ycsb-$wl-times.dat

    m3extot=$(extract_m3_stddev $1 "Totaltime:" $wl-iso)
    m3shtot=$(extract_m3_stddev $1 "Totaltime:" $wl-sh)
    lxtot=$(extract_lx_stddev $1 "Totaltime:" $wl)
    echo $m3extot $m3shtot $lxtot > $1/ycsb-$wl-stddev.dat
done
