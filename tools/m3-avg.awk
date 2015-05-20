#!/usr/bin/awk -f
{
    vals[$2][count[$2]] = $4
    total[$2] += $4
    count[$2] += 1
}

END {
    for(i in total) {
        printf "%d ", total[i] / count[i]
    }
    printf "\n"
}
