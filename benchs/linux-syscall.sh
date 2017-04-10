#!/bin/sh

extract_results() {
    awk '/>===.*/ {
        capture = 1
    }
    /<===.*/ {
        capture = 0
    }
    /^[^<>].*/ {
        if(capture == 1) {
            s = $0
            sub(/[ \t\r\n]+$/, "", s)
            printf "%s", s
        }
    }'
}

cd xtensa-linux

# ./b mkapps
# ./b mklx
# ./b mkbr

export GEM5_OUT=$1/lx-syscall
mkdir -p $GEM5_OUT

# BENCH_CMD="/bench/bin/syscall" GEM5_CP=1 ./b bench >/dev/null 2>/dev/null

extract_results < $GEM5_OUT/res.txt > $1/lx-syscall.txt
