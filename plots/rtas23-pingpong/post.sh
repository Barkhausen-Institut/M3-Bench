#!/bin/bash

. tools/helper.sh

extract_gem5_linux() {
    if [ "$2" = "riscv64" ]; then
        pl="S-RISCV"
    else
        pl="S-x86"
    fi
    grep -E "^[[:digit:]]+" "$1/lx-pingpong-$2-$3/res.txt" | while read latency; do
        echo "$pl Linux remote $latency"
    done
}

extract_gem5_nova() {
    grep -E "\[pingpong\] ! PingpongXPd.cc:[[:digit:]]+ [[:digit:]]+ ok" \
            "$1/nre-ipc-gem5-$2/system.pc.com_1.device" | awk -e '{ print($4) }' | \
        while read latency; do
            echo "S-x86 NOVA remote $latency"
        done
}

extract_hw_nova() {
    grep -E "\[pingpong\] ! PingpongXPd.cc:[[:digit:]]+ [[:digit:]]+ ok" \
            "$1/nre-ipc-hw-$2/log.txt" | awk -e '{ print($4) }' | \
        while read latency; do
            echo "H-x86 NOVA remote $latency"
        done
}

extract_m3() {
    if [ "$2" = "hw" ]; then
        pl="FPGA"
    elif [ "$2" = "gem5-riscv" ]; then
        pl="S-RISCV"
    else
        pl="S-x86"
    fi
    sed -e 's/\x1b\[0m//g' "$1/m3-ipc-$2-$3/log.txt" | \
        grep -E "^[[:digit:]]+" | while read latency; do
        echo "$pl M³ $3 $latency"
    done
}

extract_sriov() {
    while IFS="," read -r b1 b32 b256 b2032; do
        echo "H-NIC Linux remote $b1"
    done < <(tail -n +2 "$1/lx-arm-sriov.csv")
}

echo "platform os type latency" > "$1/pingpong.dat"
for isa in riscv64 x86_64; do
    extract_gem5_linux "$1" $isa 1 >> "$1/pingpong.dat"
done
extract_gem5_nova "$1" x86_64 >> "$1/pingpong.dat"
extract_hw_nova "$1" x86_64 >> "$1/pingpong.dat"
for type in remote; do
    for pl in hw gem5-riscv gem5-x86_64; do
        extract_m3 "$1" $pl $type >> "$1/pingpong.dat"
    done
done

extract_sriov "$1" >> "$1/pingpong.dat"

# TODO get real numbers
echo "H-ARM L4Re remote 1500" >> "$1/pingpong.dat"
echo "H-ARM L4Re remote 1600" >> "$1/pingpong.dat"
for i in {0..1000}; do
    echo "H-ARM L4Re remote 1550" >> "$1/pingpong.dat"
done
