#!/bin/bash

parallel="1 2 4 6 8"
dat=$1/filewriter.dat
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

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench

build_source
run_scripts filewriter gen_filewriter
extract_results
generate_plot $dat $1/filewriter.eps "Time for writing 2MB to a file" 800000

