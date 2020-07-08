#!/bin/zsh

. tools/helper.sh

cfg=b-riscv
mhz=`get_mhz $1/m3-tests-rust-benchs-$cfg-64/output.txt`

get_time() {
    grep "$2" $1/m3-tests-rust-benchs-$cfg-64/output.txt | sed -Ee 's/.*: ([0-9]+) cycles.*/\1/'
}
get_dev() {
    grep "$2" $1/m3-tests-rust-benchs-$cfg-64/output.txt | sed -Ee 's/.*\(\+\/- ([0-9\.]+) with.*/\1/'
}

for func in get_time get_dev; do
    ipcrem=$($func $1 "remote pingpong with")
    ipcloc=$($func $1 "local pingpong with")
    pexcall=$($func $1 "noop pexcall")
    tcuread=$($func $1 "TCU read (1 byte) with translate")

    if [ "$func" = "get_time" ]; then
        echo $ipcrem $ipcloc $pexcall $tcuread > $1/eval-times.dat
    else
        echo $ipcrem $ipcloc $pexcall $tcuread > $1/eval-dev.dat
    fi
done

# ! src/apps/bench/rustbenchs/src/bipc.rs:65  PERF "local pingpong with (1 * u64) msgs": 1768 cycles (+/- 4.0474997 with 100 runs)
