#!/bin/bash

# global vars
parallel="1 2 4 8 16"
declare -A scr

gen_fstrace() {
    par=$1
    cat <<'EOF'
#!/bin/sh
fs=build/$M3_TARGET-$M3_MACHINE-$M3_BUILD/$M3_FS
if [ "$M3_TARGET" = "host" ]; then
echo kernel fs=$fs
else
echo kernel
fi
echo m3fs `stat --format="%s" $fs` daemon
EOF

    i=0
    while [ $i -lt $par ]; do
        echo "echo fstrace-m3fs /tmp/$i/ requires=m3fs"
        i=$((i + 1))
    done
}

run_bench() {
    t3par=`readlink -f tools/t3-parallel.sh`

    cp benchs/trace-$2.c m3/XTSC/apps/fstrace/m3fs/trace.c

    cd m3/XTSC
    export M3_TARGET=t3 M3_MACHINE=sim M3_BUILD=bench M3_FS=bench.img M3_FSBLKS=$((32 * 1024))

    build_wo_fsrdwr
    run_scripts $t3par "$1/" scale-$2 gen_fstrace

    cd -
}

source tools/file-helper.sh

run_bench $1 tar
run_bench $1 untar
run_bench $1 find
