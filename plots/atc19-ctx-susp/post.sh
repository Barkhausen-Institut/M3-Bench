#!/bin/sh

. tools/helper.sh

get_app_idle() {
    awk -v type=$2 -v mode=$3 '
        START {
            c = 0
        }

        /DEBUG.*1ff11234/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            start = m[1]
            comstart = start
            /*print("start:", m[1])*/
            p = 1
        }
        /DEBUG.*1ff21234/ {
            match($1, /^[[:space:]]*([[:digit:]]+):/, m)
            /*print("end:", m[1])*/
            totals[c] = m[1] - start
            c += 1
            p = 0
        }

        /DEBUG.*1ff1cccc/ {
            if(p) {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                wakes[c] += m[1] - comstart
                swstart = m[1]
                /*print("sw-start:", m[1])*/
            }
        }
        /DEBUG.*1ff2cccc/ {
            if(p) {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                switches[c] += m[1] - swstart
                swend = m[1]
                /*print("sw-end:", m[1])*/
            }
        }

        /pe00.*src: pe=(3|4).*on behalf/ {
            if(p && type != "alone") {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                fwds[c] += m[1] - swend
                astart = m[1]
                /*print(">accel:", m[1])*/
            }
        }
        /pe0(4|5).*\[rv <- 3/ {
            if(p && type == "alone") {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                astart = m[1]
                /*print(">accel:", m[1])*/
            }
        }
        /pe04.*\[sd -> (5|6)\]/ {
            if(p && type == "alone") {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                astart = m[1]
                /*print(">accel:", m[1])*/
            }
        }

        /pe0(4|5|6).*\[(rp|sd) -> (3|4)]/ {
            if(p) {
                match($1, /^[[:space:]]*([[:digit:]]+):/, m)
                if(type == "sh-all")
                    comstart = m[1]
                accels[c] = m[1] - astart
                /*print("<accel:", m[1])*/
            }
        }

        function stddev(vals, avg) {
            sum = 0
            for(v in vals) {
                sum += (vals[v] - avg) * (vals[v] - avg)
            }
            return sqrt(sum / length(vals))
        }

        END {
            len = 0
            for(i in totals) len++

            sum = 0
            warmup = 8
            for(i = warmup; i < len; i++) {
                # print("totals", i, totals[i] / 1000)
                # print("wakes", i, wakes[i] / 1000)
                # print("switches", i, switches[i] / 1000)
                # print("fwds", i, fwds[i] / 1000)
                # print("accels", i, accels[i] / 1000)

                vals[i] = (totals[i] - accels[i]) / 1000
                sum += vals[i]
            }
            if(mode == "avg")
                print(sum / (len - warmup))
            else
                print(stddev(vals, sum / (len - warmup)))
        }
    ' < $1
}

echo -n > $1/ctx-susp-times.dat
echo -n > $1/ctx-susp-stddev.dat

for v in sh-all sh-srv alone; do
    get_app_idle $1/m3-ctx-susp-c-$v/gem5.log $v avg >> $1/ctx-susp-times.dat
    get_app_idle $1/m3-ctx-susp-c-$v/gem5.log $v stddev >> $1/ctx-susp-stddev.dat
done
for t in b a; do
    for v in shared alone; do
        get_app_idle $1/m3-ctx-susp-$t-$v/gem5.log $v avg >> $1/ctx-susp-times.dat
        get_app_idle $1/m3-ctx-susp-$t-$v/gem5.log $v stddev >> $1/ctx-susp-stddev.dat
    done
done
