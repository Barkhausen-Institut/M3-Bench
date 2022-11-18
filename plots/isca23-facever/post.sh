#!/bin/bash

. tools/helper.sh

extract_m3() {
    sed -e 's/\x1b\[0m//g' "$1/m3-facever-$2/log.txt" | awk -e '
        /xfer: / {
            xfers = $1
            if (count >= 2) {
                printf("M³ '"$2"' Transfers %d\n", $2)
            }
        }
        /total: / {
            total = $2
        }
        /compute: / {
            count += 1
            if (count > 2) {
                printf("M³ '"$2"' Compute %d\n", $2)
                printf("M³ '"$2"' RPCs %d\n", total - ($2 + xfers))
            }
        }
    '
}

extract_shm() {
    awk -e '
        /total: / {
            replay += 1
            if (replay > 100) {
                if (match($0, /total: ([0-9]+) cycles, xfer: ([0-9]+) cycles, comp: ([0-9]+) cycles/, m) != 0) {
                    printf("IPIs '"$2"' Transfers %d\n", m[2])
                    printf("IPIs '"$2"' RPCs %d\n", m[1] - (m[2] + m[3]))
                    printf("IPIs '"$2"' Compute %d\n", m[3])
                }
            }
        }
    ' "$1/shm-facever/log-$2.txt"
}

# the FractOS CPU supposedly didn't run in Turbomode due to too much load and therefore at 2.1GHz
wl256=$(echo "256 * 2100" | bc)
wl512=$(echo "512 * 2100" | bc)
wl1024=$(echo "1024 * 2100" | bc)
# from the FractOS benchmark scripts: assume 0.3 for storage time, 1.3 for GPU time
comp256=$(printf "%.0f" $(echo "$wl256 * 1.3 + $wl256 * 0.3 + 10000" | bc))
comp512=$(printf "%.0f" $(echo "$wl512 * 1.3 + $wl512 * 0.3 + 10000" | bc))
comp1024=$(printf "%.0f" $(echo "$wl1024 * 1.3 + $wl1024 * 0.3 + 10000" | bc))

extract_sriov() {
    OLDIFS=$IFS
    IFS=","
    tail -n +102 "$1/sriov-facever/results.csv" | while read t256 x256 t512 x512 t1024 x1024; do
        echo "SR-IOV $((256 * 1024)) Transfers $x256"
        echo "SR-IOV $((256 * 1024)) RPCs $((t256 - (x256 + comp256)))"
        echo "SR-IOV $((256 * 1024)) Compute $comp256"
        echo "SR-IOV $((512 * 1024)) Transfers $x512"
        echo "SR-IOV $((512 * 1024)) RPCs $((t512 - (x512 + comp512)))"
        echo "SR-IOV $((512 * 1024)) Compute $comp512"
        echo "SR-IOV $((1024 * 1024)) Transfers $x1024"
        echo "SR-IOV $((1024 * 1024)) RPCs $((t1024 - (x1024 + comp1024)))"
        echo "SR-IOV $((1024 * 1024)) Compute $comp1024"
    done
    IFS=$OLDIFS
}

echo "platform size type latency" > "$1/facever.dat"
for s in 262144 524288 1048576; do
    extract_m3 "$1" "$s" >> "$1/facever.dat"
    extract_shm "$1" "$s" >> "$1/facever.dat"
done
extract_sriov "$1" >> "$1/facever.dat"

# for s in 0 262144 524288 1048576; do
#     for i in {0..10}; do
#         echo "SR-IOV $s Transfers $((20000 + (s / 4)))" >> "$1/facever.dat"
#         echo "SR-IOV $s RPCs $(((15000) * 5))" >> "$1/facever.dat"
#         comp=$(grep "MMU+IPIs $s Compute" "$1/facever.dat" | head -n 1 | awk '{ print($4) }')
#         echo "SR-IOV $s Compute $comp" >> "$1/facever.dat"
#     done
# done
