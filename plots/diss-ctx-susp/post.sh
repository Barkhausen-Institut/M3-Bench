#!/bin/sh

. tools/helper.sh

get_app_idle() {
    awk -v type=$2 '
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

        END {
            len = 0
            for(i in totals) len++

            wakeup_sum = 0
            switch_sum = 0
            fwds_sum = 0
            rem_sum = 0
            warmup = 8
            for(i = warmup; i < len; i++) {
                # print("totals", i, totals[i] / 1000)
                # print("wakes", i, wakes[i] / 1000)
                # print("switches", i, switches[i] / 1000)
                # print("fwds", i, fwds[i] / 1000)
                # print("accels", i, accels[i] / 1000)

                wakeup_sum  += wakes[i] / 1000
                switch_sum += switches[i] / 1000
                fwds_sum += fwds[i] / 1000
                rem_sum  += (totals[i] - (wakes[i] + switches[i] + fwds[i])) / 1000
            }
            print(wakeup_sum / (len - warmup),
                  switch_sum / (len - warmup),
                  fwds_sum / (len - warmup),
                  rem_sum / (len - warmup))
        }
    ' < $1
}

nova_total() {
    grep -P '! PingpongXPd\.cc.* \d+ cycles' $1/nre/gem5.log | \
        sed -Ee 's/.* ([[:digit:]]+) cycles.*/\1/'
}

echo -n > $1/ctx-susp-times.dat

for v in sh-all sh-srv alone; do
    get_app_idle $1/m3-ctx-susp-c-$v/gem5.log $v >> $1/ctx-susp-times.dat
done
for t in b a; do
    for v in shared alone; do
        get_app_idle $1/m3-ctx-susp-$t-$v/gem5.log $v >> $1/ctx-susp-times.dat
    done
done

novarem=`nova_total $1 | head -n 1`
echo 0 0 0 $((novarem / 3)) >> $1/ctx-susp-times.dat
novaloc=`nova_total $1 | tail -n 1`
echo 0 0 0 $((novaloc / 3)) >> $1/ctx-susp-times.dat
