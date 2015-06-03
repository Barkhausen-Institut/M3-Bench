#!/bin/bash

# global vars
parallel="1 2 4 8 16"
declare -A scr

gen_filewriter() {
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
        echo "echo filewriter /test$i.bin $((2 * 1024 * 1024)) requires=m3fs"
        i=$((i + 1))
    done
}

source tools/file-helper.sh

t3par=`readlink -f tools/t3-parallel.sh`

cd m3/XTSC
export M3_TARGET=t3 M3_MACHINE=sim M3_BUILD=bench M3_FSBLKS=$((48 * 1024))

build_source
run_scripts $t3par "$1/" filewriter gen_filewriter

cd -

extract_results $1/filewriter.dat
