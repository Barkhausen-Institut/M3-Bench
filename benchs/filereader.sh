#!/bin/bash

parallel="1 2 4 8 16"
dat=$1/filereader.dat
declare -A scr

gen_filereader() {
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
        echo "echo filereader /large.bin requires=m3fs"
        i=$((i + 1))
    done
}

source tools/file-helper.sh

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench

build_source
run_scripts filereader gen_filereader
extract_results
generate_plot $dat $1/filereader.eps "Time for reading a 2MB file from the FS" 500000
