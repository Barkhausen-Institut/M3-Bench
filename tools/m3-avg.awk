#!/usr/bin/awk -f
{
    vals[$2][count[$2]] = $4
    total[$2] += $4
    count[$2] += 1
}

END {
    for(len in total);
    for(i in total) {
        printf "%d", total[i] / count[i]
        if(i + 1 < len)
            printf(" ")
    }
    printf "\n"
}
