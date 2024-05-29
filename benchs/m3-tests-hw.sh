#!/bin/bash

inputdir=$(readlink -f input)

. tools/helper.sh

cd m3 || exit 1

export M3_ISA=riscv64
export M3_HW_FPGA_HOST=bitest
export M3_HW_FPGA_DIR=m3
export M3_HW_FPGA_NO=1
export M3_HW_VIVADO=/home/hrniels/Applications/Xilinx/Vivado_Lab/2019.1/bin/vivado_lab
export M3_HW_RESET=1
export M3_HW_TIMEOUT=120
export M3_HW_TTY=/dev/ttyUSB2

run_bench() {
    bpe=$6
    dirname=m3-tests-$2-$3-$4-$5-$6
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    bootprefix=""
    if [ "$4" = "sh" ]; then
        bootprefix="shared/"
    fi
    if [ "$4" = "spm" ]; then
        export M3_HW_VM=0
    else
        export M3_HW_VM=1
    fi

    bench=$2

    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ] || [ "$bench" = "hashmux-tests" ] ||
       [ "$bench" = "facever" ] || [ "$bench" = "filterchain" ]; then
        export M3_FS=default-$bpe.img
        cp "boot/${bootprefix}$bench.xml" "$M3_OUT/boot.gen.xml"
    elif [ "$bench" = "standalone" ] || [ "$bench" = "memtest" ] || [ "$bench" = "standalone-sndrcv" ]; then
        unset M3_HW_VM
        cp "boot/$bench.xml" "$M3_OUT/boot.gen.xml"
    elif [[ "$bench" == lx* ]]; then
        cp "boot/linux/${bench#lx}.xml" "$M3_OUT/boot.gen.xml"
    elif [ "$bench" = "hello" ]; then
        cp "boot/${bootprefix}$bench.xml" "$M3_OUT/boot.gen.xml"
    else
        export M3_FS=bench-$bpe.img

        if [[ "$bench" =~ "bench" ]]; then
            cp "boot/${bootprefix}$bench.xml" "$M3_OUT/boot.gen.xml"
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_ACCEL_COUNT=0 M3_ARGS="-i 1 -r 2 -w 1 $writer $reader"
            "$inputdir/${bootprefix}bench-scale-pipe.cfg" > "$M3_OUT/boot.gen.xml"
        else
            export M3_ARGS="-n 4 -t -u 1 $bench"
            "$inputdir/${bootprefix}fstrace.cfg" > "$M3_OUT/boot.gen.xml"
        fi
    fi

    i=0
    while [ $i -lt 10 ]; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        if ./b run "$M3_OUT/boot.gen.xml" -n > "$M3_OUT/output.txt" 2>&1 \
            && ../tools/check_result.py "$M3_OUT/output.txt" 2>/dev/null; then
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
            break
        else
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
            # if the kernel didn't start, we assume that there is something fundamentally wrong and
            # therefore reinstall the bitfile.
            if [ "$(grep --text 'Kernel is ready' "$M3_OUT/output.txt")" = "" ]; then
                reset_bitfile
            # if there was a NoC/Mem timeout, repeat the test
            elif [ "$(grep --text 'TimeoutNoC\|TimeoutMem' "$M3_OUT/output.txt")" != "" ]; then
                continue
            # otherwise, don't repeat the test
            else
                break
            fi
        fi
        i=$((i + 1))
    done
}

for target in hw22 hw23; do
    for btype in debug bench; do
        # build everything
        export M3_BUILD=$btype M3_TARGET=$target
        ./b || exit 1

        # create FS images
        build=build/$M3_TARGET-$M3_ISA-$M3_BUILD
        $build/toolsbin/mkm3fs "$build/bench-$bpe.img" "$build/src/fs/bench" $((64 * 1024)) 4096 64
        $build/toolsbin/mkm3fs "$build/default-$bpe.img" "$build/src/fs/default" $((16 * 1024)) 512 64
    done
done

# build m3lx
M3_BUILD=bench ./b mklx -n || exit 1

benchs=""
#benchs+="rust-unittests"
benchs+="rust-benchs"
benchs+=" unittests cpp-benchs"
benchs+=" facever"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
#benchs+=" cat_awk cat_wc grep_awk grep_wc"
benchs+=" standalone memtest standalone-sndrcv"
benchs+=" hello"
benchs+=" bench-shell filterchain"
benchs+=" lxrust-benchs lxcpp-benchs lxtcutest"

# run user-specified tests?
if [ "$M3_TESTS" != "" ]; then
    benchs="$M3_TESTS"
fi

for target in hw22 hw23; do
    # load the correct bitfile upfront in case we have one that is somewhat but not fully compatible
    if [ "$target" = "hw23" ]; then
        ./b loadfpga=fpga_top_v4.6.0.bit -n
    elif [ "$target" = "hw22" ]; then
        ./b loadfpga=fpga_top_v4.4.12.bit -n
    fi

    for build in debug bench; do
        for ty in ex sh spm; do
            export M3_BUILD=$build M3_TARGET=$target

            for test in $benchs; do
                # M³Linux is not supported on hw22 because its TCU lacks support for 64-bit virtual addresses
                if [[ "$test" == lx* ]] && [ "$M3_TARGET" = "hw22" ]; then
                    continue
                fi
                # in debug mode there are too many issues right now, so just run hello
                if [ "$M3_BUILD" = "debug" ] && [ "$test" != "hello" ]; then
                    continue
                fi
                # for some tests we don't have a shared version
                if [ "$ty" = "sh" ] && { [ "$test" = "standalone" ] || [ "$test" = "memtest" ] ||
                                         [ "$test" = "standalone-sndrcv" ] || [ "$test" = "filterchain" ] ||
                                         [[ "$test" == lx* ]]; }; then
                    continue
                fi
                # for now, only run hello with our emulated SPM
                if [ "$ty" = "spm" ] && [ "$test" != "hello" ]; then
                    continue
                fi

                run_bench "$1" "$test" "$M3_TARGET-$build" "$ty" "$M3_ISA" 64
            done
        done
    done
done
