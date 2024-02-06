#!/bin/bash

inputdir=`readlink -f input`

. tools/jobs.sh

cd m3

export M3_TARGET=gem5
if [ -z $M3_GEM5_LOG ]; then
	export M3_GEM5_LOG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
fi
export M3_GEM5_CPUFREQ=3GHz M3_GEM5_MEMFREQ=1GHz
export M3_CORES=12
export M3_GEM5_CFG=$inputdir/test-config.py

run_bench() {
    export M3_ISA=$4
    export M3_TILETYPE=$3
    export ACCEL_NUM=0
    dirname=m3-tests-$2-$3-$4-$5
    bpe=$5
    bench=$2
    export M3_OUT=$1/$dirname
    mkdir -p $M3_OUT

    bootprefix=""
    if [ "$3" = "coverage" ]; then
        export M3_TILETYPE=b
    fi
    if [ "$3" = "sh" ]; then
        export M3_TILETYPE=b
        bootprefix="shared/"
    elif [[ "$bench" =~ "ycsb-bench" ]]; then
        bootprefix=""
    fi
    if [ "$5" = "64" ]; then
        export M3_GEM5_CPU=DerivO3CPU
    else
        export M3_GEM5_CPU=TimingSimpleCPU
    fi

    # we always use the FS images generated below
    export M3_MOD_PATH=build/$M3_TARGET-$M3_ISA-$M3_BUILD/fsimgs-$bpe

    if [ "$bench" = "unittests" ] || [ "$bench" = "rust-unittests" ] || [ "$bench" = "hello" ] ||
        [ "$bench" = "rust-net-tests" ] || [ "$bench" = "cpp-net-tests" ] || [ "$bench" = "facever" ] ||
        [ "$bench" = "hashmux-tests" ] || [ "$bench" = "msgchan" ] || [ "$bench" = "resmngtest" ] ||
        [ "$bench" = "standalone" ] || [ "$bench" = "vmtest" ] || [ "$bench" = "rust-sndrcv" ] ||
        [ "$bench" = "libctest" ] || [ "$bench" = "rust-std-test" ] || [ "$bench" = "filterchain" ] ||
        [ "$bench" = "parchksum" ] || [ "$bench" = "shell-nested" ] || [ "$bench" = "chantests" ]; then
        if [ -f boot/${bootprefix}$bench.xml ]; then
            cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
        else
            cp boot/$bench.xml $M3_OUT/boot.gen.xml
        fi
        if [ "$bench" = "hello" ]; then
            export M3_BUILD=debug
        elif [ "$bench" = "standalone" ]; then
            export M3_GEM5_CFG=config/spm.py M3_CORES=8
        fi
    elif [[ "$bench" == lx* ]]; then
        cp boot/linux/${bench#lx}.xml $M3_OUT/boot.gen.xml
    elif [ "$bench" = "disk-test" ]; then
        export M3_GEM5_HDD=$inputdir/test-hdd.img
        cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
    elif [ "$bench" = "abort-test" ]; then
        export M3_GEM5_CFG=config/aborttest.py
        cp boot/hello.xml $M3_OUT/boot.gen.xml
    else
        if [[ "$bench" =~ "bench" ]] || [[ "$bench" =~ "voiceassist" ]]; then
            if [ "$bench" = "hashmux-benchs" ]; then
                export M3_CORES=18
            fi
            cp boot/${bootprefix}$bench.xml $M3_OUT/boot.gen.xml
        elif [[ "$bench" =~ "_" ]]; then
            IFS='_' read -ra parts <<< "$bench"
            writer=${parts[0]}_${parts[1]}_${parts[0]}
            reader=${parts[0]}_${parts[1]}_${parts[1]}
            export M3_ARGS="-d -i 1 -r 4 -w 1 $writer $reader"
            $inputdir/${bootprefix}bench-scale-pipe.cfg > $M3_OUT/boot.gen.xml
        elif [[ "$bench" =~ "imgproc" ]]; then
            IFS='-' read -ra parts <<< "$bench"
            if [ "${parts[1]}" = "indir" ]; then
                export M3_ACCEL_TYPE="indir"
            else
                export M3_ACCEL_TYPE="copy"
            fi
            export M3_ACCEL_COUNT=$((${parts[2]} * 3))
            export M3_ARGS="-m ${parts[1]} -n ${parts[2]} -w 1 -r 4 /large.txt"
            $inputdir/${bootprefix}imgproc.cfg > $M3_OUT/boot.gen.xml
        else
            export M3_ARGS="-n 4 -t -d -u 1 $bench"
            $inputdir/${bootprefix}fstrace.cfg > $M3_OUT/boot.gen.xml
        fi
    fi

    /bin/echo -e "\e[1mStarting $dirname\e[0m"
    jobs_started

    # set memory and time limits
    if [ "$M3_BUILD" = "coverage" ] || [ "$M3_GEM5_CPU" = "DerivO3CPU" ]; then
        ulimit -v 12000000   # 12GB virt mem
        ulimit -t 3000      # 50min CPU time
    else
        ulimit -v 7000000   # 6GB virt mem
        ulimit -t 1500      # 25min CPU time
    fi

    nice ./b run $M3_OUT/boot.gen.xml -n < /dev/null > $M3_OUT/output.txt 2>&1

    gzip -f $M3_OUT/gem5.log

    if [ $? -eq 0 ] && ../tools/check_result.py $M3_OUT/output.txt 2>/dev/null; then
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
    else
        /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
    fi
}

build_types="debug bench coverage"
build_isas="riscv x86_64 arm"
run_isas="riscv x86_64"

if [ "$M3_TEST" != "" ]; then
    test_args=$(python3 -c '
import sys
p = sys.argv[1].split("-")
if len(p) < 4:
    sys.exit(1)
print("{} {} {} {}".format("-".join(p[:-3]), p[-3], p[-2], p[-1]))
' $M3_TEST) || ( echo "Please set M3_TEST to <bench>-<tiletype>-<isa>-<bpe>." && exit 1 )
fi

if [ "$M3_TEST" != "" ]; then
    build_isas=$(echo $test_args | cut -d ' ' -f 3)
    if [[ $test_args == *coverage* ]]; then
        export M3_BUILD=coverage
    elif [[ $M3_TEST == hello-* ]]; then
        export M3_BUILD=debug
    elif [ "$M3_LOG" != "" ]; then
        export M3_BUILD=release
    else
        export M3_BUILD=bench
    fi
    build_types="$M3_BUILD"
fi

for btype in $build_types; do
    for isa in $build_isas; do
        # we only generate coverage for riscv
        if [ "$btype" = "coverage" ] && [ "$isa" != "riscv" ]; then
            continue
        fi

        # build everything
        export M3_ISA=$isa
        M3_BUILD=$btype ./b || exit 1

        # create FS images
        build=build/$M3_TARGET-$M3_ISA-$btype
        for bpe in 32 64; do
            bmoddir=build/$M3_TARGET-$M3_ISA-$btype/fsimgs-$bpe
            mkdir -p $bmoddir

            case "$btype" in
                coverage) benchblks=$((160*1024)); defblks=$((160*1024)) ;;
                *)        benchblks=$((64*1024)); defblks=$((16*1024)) ;;
            esac

            $build/toolsbin/mkm3fs $bmoddir/bench.img $build/src/fs/bench $benchblks 4096 $bpe
            $build/toolsbin/mkm3fs $bmoddir/default.img $build/src/fs/default $defblks 512 $bpe
        done
   done
done

# build m3lx
if [[ "$build_isas" == *riscv* ]] && ( [ "$M3_TEST" = "" ] || [[ "$M3_TEST" == lx* ]] ); then
    M3_ISA=riscv M3_BUILD=bench ./b mklx -n || exit 1
fi

jobs_init $2

# run a single test?
if [ "$M3_TEST" != "" ]; then
    jobs_submit run_bench $1 $test_args
    jobs_wait
    exit 0
fi

benchs=""
benchs+="rust-unittests hashmux-tests rust-benchs unittests cpp-benchs hashmux-benchs resmngtest"
benchs+=" rust-net-tests cpp-net-tests rust-net-benchs cpp-net-benchs facever"
benchs+=" find tar untar sqlite leveldb sha256sum sort"
benchs+=" cat_awk cat_wc grep_awk grep_wc"
benchs+=" disk-test abort-test"
benchs+=" standalone libctest rust-std-test msgchan rust-sndrcv vmtest"
benchs+=" ycsb-bench-udp ycsb-bench-tcp"
benchs+=" voiceassist-udp voiceassist-tcp"
benchs+=" bench-shell shell-nested parchksum filterchain"
benchs+=" chantests"
benchs+=" lxrust-benchs lxcpp-benchs lxtcutest"
# only 1 chain with indirect, because otherwise we would need more than 16 EPs
benchs+=" imgproc-indir-1"
for num in 1 2 3 4; do
    benchs+=" imgproc-dir-$num"
done

# run user-specified tests?
if [ "$M3_TESTS" != "" ]; then
    benchs="$M3_TESTS"
fi

export M3_BUILD=bench
for bpe in 32 64; do
   for isa in $run_isas; do
       for tiletype in a b sh; do
           for test in $benchs; do
                # standalone works only with SPM
                if [ "$test" = "standalone" ] && [ "$tiletype" != "a" ]; then
                    continue;
                fi
                # rust-sndrcv and vmtest don't run with SPM
                if ( [ "$test" = "rust-sndrcv" ] || [ "$test" = "vmtest" ] ) && [ "$tiletype" = "a" ]; then
                    continue;
                fi
                # m3lx runs only on riscv and has no shared version
                if [[ "$test" == lx* ]] && ( [ "$isa" != "riscv" ] || [ "$tiletype" != "b" ] ); then
                    continue;
                fi

                jobs_submit run_bench $1 $test $tiletype $isa $bpe
            done
        done
    done
done

# generate code coverage
export M3_BUILD=coverage
for test in $benchs; do
    # standalone works only with SPM
    if [ "$test" = "standalone" ]; then
        continue;
    fi

    jobs_submit run_bench $1 $test coverage riscv 32
done

jobs_wait

