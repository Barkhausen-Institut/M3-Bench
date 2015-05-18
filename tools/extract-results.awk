#!/usr/bin/awk -f
function stddev(vals, avg) {
    sum = 0
    for(v in vals) {
        sum += (vals[v] - avg) * (vals[v] - avg)
    }
    return sqrt(sum / length(vals))
}

{
    vals[$2][count[$2]] = $4
    total[$2] += $4
    count[$2] += 1
}

END {
    for(i in vals) {
        printf "%d %d ", total[i] / count[i], stddev(vals[i], total[i] / count[i])
    }
    printf "\n"
}
