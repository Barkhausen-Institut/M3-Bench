#!/bin/bash

# global vars
parallel="1"
declare -A scr

gen_config() {
    cat <<'EOF'
#!/bin/sh
fs=build/$M3_TARGET-$M3_MACHINE-$M3_BUILD/$M3_FS
if [ "$M3_TARGET" = "host" ]; then
echo kernel fs=$fs
else
echo kernel
fi
echo m3fs `stat --format="%s" $fs` daemon
echo pipetr /largetext.txt /tmp/res.txt a b requires=m3fs
EOF
}

source tools/file-helper.sh

t3par=`readlink -f tools/t3-parallel.sh`

cd m3/XTSC
export M3_TARGET=t3 M3_MACHINE=sim M3_BUILD=bench M3_FS=bench.img

build_for_pipetr
run_scripts $t3par "$1/" m3-pipetr gen_config
