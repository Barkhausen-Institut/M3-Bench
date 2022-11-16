#!/bin/bash

. tools/helper.sh

extract_m3() {
    sed -e 's/\x1b\[0m//g' "$1/m3-facever-$2/log.txt" | awk -e '
        /xfer: / {
            xfers = $1
            if (count >= 10) {
                printf("M³ '"$2"' Transfers %d\n", $2)
            }
        }
        /total: / {
            total = $2
        }
        /compute: / {
            count += 1
            if (count > 10) {
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
                    printf("MMU+IPIs '"$2"' Transfers %d\n", m[2])
                    printf("MMU+IPIs '"$2"' RPCs %d\n", m[1] - (m[2] + m[3]))
                    printf("MMU+IPIs '"$2"' Compute %d\n", m[3])
                }
            }
        }
    ' "$1/shm-facever/log-$2.txt"
}

echo "platform size type latency" > "$1/facever.dat"
for s in 0 262144 524288 1048576; do
    extract_m3 "$1" "$s" >> "$1/facever.dat"
    extract_shm "$1" "$s" >> "$1/facever.dat"
done

for s in 0 262144 524288 1048576; do
    for i in {0..10}; do
        echo "SR-IOV $s Transfers $((3000 + s))" >> "$1/facever.dat"
        echo "SR-IOV $s RPCs $(((50000 + 2560) * 5))" >> "$1/facever.dat"
        comp=$(grep "MMU+IPIs $s Compute" "$1/facever.dat" | head -n 1 | awk '{ print($4) }')
        echo "SR-IOV $s Compute $comp" >> "$1/facever.dat"
    done
done
