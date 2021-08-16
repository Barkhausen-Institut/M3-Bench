#!/bin/sh

. tools/helper.sh

extract_m3_time() {
    grep "Runtime:" $1 | \
        sed -e 's/\x1b\[0m//g' | \
        sed -re 's/.*Runtime: ([0-9]* [0-9]*).*/\1/'
}

extract_vpe_stats() {
    grep "Destroyed VPE $2" $1 | \
        sed -e 's/\x1b\[0m//g' | \
        sed -re 's/.*VPE [0-9]* \(([0-9]*)ns CPU time, ([0-9]*) context.*/\1 \2/'
}

cycles_to_time() {
    # cycles to us
    echo "scale=5; 1000000 / (80000000 / $1)" | bc
}

ctxsw_costs() {
    swtime=$(cycles_to_time $(($1 * 3000)))
    echo "scale=5; 100 * ($swtime / $2)" | bc
}

timeex=$(extract_m3_time $1/m3-voiceassist/output.txt | cut -d ' ' -f 1)
timesh=$(extract_m3_time $1/m3-voiceassist-shared/output.txt | cut -d ' ' -f 1)
vpe2=$(extract_vpe_stats $1/m3-voiceassist-shared/output.txt 2 | cut -d ' ' -f 1)
vpe3=$(extract_vpe_stats $1/m3-voiceassist-shared/output.txt 3 | cut -d ' ' -f 1)
ctxsw=$(extract_vpe_stats $1/m3-voiceassist-shared/output.txt 5 | cut -d ' ' -f 2)
echo $timeex 0 0 > $1/audio-times.dat
echo $timesh 0 0 >> $1/audio-times.dat
echo $(ctxsw_costs $ctxsw $timeex) >> $1/audio-times.dat
echo $(($vpe2 / 16)) >> $1/audio-times.dat
echo $(($vpe3 / 16)) >> $1/audio-times.dat
echo $timeex $((($vpe2 + $vpe3) / 16)) $(((($vpe2 + $vpe3) - ($timesh - $timeex)) / 16)) >> $1/audio-times.dat

timeex=$(extract_m3_time $1/m3-voiceassist/output.txt | cut -d ' ' -f 2)
timesh=$(extract_m3_time $1/m3-voiceassist-shared/output.txt | cut -d ' ' -f 2)
echo $timeex $timesh 0 > $1/audio-stddev.dat
