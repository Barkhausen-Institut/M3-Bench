#!/bin/sh

cd m3/XTSC
export M3_TARGET=t3 M3_BUILD=bench

parallel="1 2 4 8 16"
dat=$1/ls.dat
declare -A scr

gen_ls() {
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
        echo "echo ls / requires=m3fs"
        i=$((i + 1))
    done
}

source tools/file-helper.sh

build_source
run_scripts ls gen_ls
extract_results
generate_plot $dat $1/ls.eps "Time for listing a directory" 500000