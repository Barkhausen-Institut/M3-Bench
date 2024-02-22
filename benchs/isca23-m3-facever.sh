#!/bin/bash

inputdir=$(readlink -f input)

source tools/helper.sh

cd m3 || exit 1

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_VM=1 M3_HW_RESET=1
export M3_HW_TIMEOUT=120

./b || exit 1

run_bench() {
    size="$2"
    gpu="$3"
    storage="$4"
    fs="$5"

    dirname=m3-facever-$size
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    while true; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        export M3_FS_COMP=$fs
        export M3_GPU_COMP=$gpu
        export M3_STORAGE_COMP=$storage
        export M3_DATA_SIZE=$size
        export M3_RUNS=10

        "$inputdir/facever.cfg" > "$M3_OUT/boot.gen.xml"
        ./b run "$M3_OUT/boot.gen.xml" -n 2>&1 | tee "$M3_OUT/output.txt"

        sed --in-place -e 's/\x1b\[0m//g' "$M3_OUT/output.txt"

        if bench_succeeded "$dirname" "$M3_OUT/output.txt" 'All childs gone. Exiting.'; then
            break
        fi
    done
}

run_bench "$1" 0 0 0 0

# the FractOS CPU supposedly didn't run in Turbomode due to too much load and therefore at 2.1GHz
wl256=$(echo "256 * 2100" | bc)
wl512=$(echo "512 * 2100" | bc)
wl1024=$(echo "1024 * 2100" | bc)

# from the FractOS benchmark scripts: assume 0.3 for storage time, 1.3 for GPU time
run_bench "$1" \
    $((256 * 1024)) \
    "$(printf "%.0f" "$(echo "$wl256 * 1.3" | bc)")" \
    "$(printf "%.0f" "$(echo "$wl256 * 0.3" | bc)")" \
    10000

run_bench "$1" \
    $((512 * 1024)) \
    "$(printf "%.0f" "$(echo "$wl512 * 1.3" | bc)")" \
    "$(printf "%.0f" "$(echo "$wl512 * 0.3" | bc)")" \
    10000

run_bench "$1" \
    $((1024 * 1024)) \
    "$(printf "%.0f" "$(echo "$wl1024 * 1.3" | bc)")" \
    "$(printf "%.0f" "$(echo "$wl1024 * 0.3" | bc)")" \
    10000

