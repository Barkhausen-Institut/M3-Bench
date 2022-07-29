#!/bin/sh

. tools/helper.sh

extract_avg() {
    echo -n "pingpong-$2-$3: "
    awk -e '
        BEGIN {
            sum = 0
            count = 0
        }
        /^[[:digit:]]+/ {
            if($1 < 200000) {
                vals[count] = $1
                sum += $1
                count += 1
            }
            else {
                #printf("Ignoring outlier %d\n", $1)
            }
        }
        END {
            avg = sum / count
            sdsum = 0
            for(v in vals)
                sdsum += (vals[v] - avg) * (vals[v] - avg)
            print(avg, sqrt(sdsum / count))
        }
    ' "$1/lx-pingpong-$2-$3/res.txt"
}

for cores in 2 4 6; do
    for msgsz in 1 32 256 2032; do
        extract_avg "$1" $cores $msgsz
    done
done