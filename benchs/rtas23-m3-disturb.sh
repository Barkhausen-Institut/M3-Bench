#!/bin/bash

. tools/helper.sh
. tools/jobs.sh

if [ "$M3_TARGET" = "" ]; then
    echo "Please define M3_TARGET!" >&2 && exit 1
fi

cd m3 || exit 1

export M3_BUILD=release
export M3_ISA=riscv
if [ "$M3_TARGET" = "hw" ]; then
    export M3_HW_SSH=bitest M3_HW_FPGA=1
    export M3_HW_RESET=1
    export M3_HW_TIMEOUT=120
else
    export M3_GEM5_DBG=Tcu,TcuRegWrite,TcuCmd,TcuConnector
    export M3_GEM5_CPU=DerivO3CPU
    export M3_GEM5_CPUFREQ=2GHz M3_GEM5_MEMFREQ=1GHz
    export M3_CORES=12
    export M3_GEM5_CFG=config/caches.py
fi

./b || exit 1

tmpdir=$(mktemp -d)
trap 'rm -rf -- "$tmpdir"' EXIT

run_bench() {
    bw=$2
    fgm=$3
    bgm=$4
    dirname=m3-disturb-$M3_TARGET-$bw-$fgm-$bgm
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    cfg="$tmpdir/disturb-$fgm-$bgm.xml"
    gen_config "$bw" "$fgm" "$bgm" > "$cfg"
    jobs_started

    i=0
    while [ $i -lt 2 ]; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"
   
        if [ "$M3_TARGET" = "hw" ]; then 
            ./b run "$cfg" -n &> "$M3_OUT/output.txt"
        else
            ./b run "$cfg" -n < /dev/null &> "$M3_OUT/output.txt"
        fi

        if [ $? -eq 0 ] && [ "$(grep 'Shutting down' "$M3_OUT/output.txt")" != "" ]; then
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
            break
        else
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
            # if the kernel didn't start, we assume that there is something fundamentally wrong and
            # therefore reinstall the bitfile.
            if [ "$M3_TARGET" = "hw" ] && [ "$(grep 'Kernel is ready' "$M3_OUT/output.txt")" = "" ]; then
                reset_bitfile
            # otherwise, don't repeat the test
            else
                break
            fi
        fi
        i=$((i + 1))
    done
}

gen_config() {
    bw=$1
    fgmode=$2
    bgmode=$3

    echo "<config>"
    echo "    <kernel args=\"kernel\" />"
    echo "    <dom>"
    echo "        <app args=\"root sem=ready1 sem=ready0 sem=ready2\">"
    if [ "$bgmode" != "none" ]; then
        if [ "$fgmode" != "msgs" ]; then
            others=5
        else
            others=4
        fi
        if [ "$bgmode" = "msgs" ]; then
            others=$((others - 1))
        fi
        i=0
        while [ $i -lt $others ]; do
            if [ "$bgmode" != "msgs" ]; then
                if [ $((i + 1)) -ge $others ]; then
                    echo "            <dom tile=\"boom+nic|core\">"
                else
                    echo "            <dom>"
                fi
                if [ "$bw" != "0" ]; then
                    echo "                <app args=\"disturber $bgmode 100000\" daemon=\"1\" mem-bw=\"$bw\">"
                else
                    echo "                <app args=\"disturber $bgmode 100000\" daemon=\"1\">"
                fi
                echo "                </app>"
                echo "            </dom>"
                i=$((i + 1))
            else
                echo "            <dom>"
                if [ "$bw" != "0" ]; then
                    echo "                <app args=\"ppsender 100000 0 2032 0\" daemon=\"1\" mem-bw=\"$bw\">"
                else
                    echo "                <app args=\"ppsender 100000 0 2032 0\" daemon=\"1\">"
                fi
                echo "                    <sgate lname=\"chan\" gname=\"chan$i\" label=\"1\" />"
                echo "                    <sem lname=\"ready\" gname=\"ready$i\" />"
                echo "                </app>"
                echo "            </dom>"
                if [ $((i + 2)) -ge $others ]; then
                    echo "            <dom tile=\"boom+nic|core\">"
                else
                    echo "            <dom>"
                fi
                if [ "$bw" != "0" ]; then
                    echo "                <app args=\"ppreceiver 100000 2032\" daemon=\"1\" mem-bw=\"$bw\">"
                else
                    echo "                <app args=\"ppreceiver 100000 2032\" daemon=\"1\">"
                fi
                echo "                    <rgate lname=\"chan\" gname=\"chan$i\" msgsize=\"2048\" slots=\"1\" />"
                echo "                    <sem lname=\"ready\" gname=\"ready$i\" />"
                echo "                </app>"
                echo "            </dom>"
                i=$((i + 2))
            fi
        done
    fi
    if [ "$fgmode" != "msgs" ]; then
        echo "            <dom tile=\"boom|core\">"
        echo "                <app args=\"disturber $fgmode 100\">"
        echo "                </app>"
        echo "            </dom>"
    else
        echo "            <dom tile=\"boom|core\">"
        echo "                <app args=\"ppsender 10000 100 2032 1\">"
        echo "                    <sgate lname=\"chan\" gname=\"chan1\" label=\"1\" />"
        echo "                    <sem lname=\"ready\" gname=\"ready1\" />"
        echo "                </app>"
        echo "            </dom>"
        echo "            <dom tile=\"boom|core\">"
        echo "                <app args=\"ppreceiver 10100 2032\">"
        echo "                    <rgate lname=\"chan\" gname=\"chan1\" msgsize=\"2048\" slots=\"1\" />"
        echo "                    <sem lname=\"ready\" gname=\"ready1\" />"
        echo "                </app>"
        echo "            </dom>"
    fi
    echo "        </app>"
    echo "    </dom>"
    echo "</config>"
}

jobs_init "$2"

for bw in 0 4K 16K 64K 256K 1024K 4096K; do
    if [ "$M3_TARGET" = "hw" ] && [ "$bw" != "0" ]; then
        continue
    fi

    for fgm in compute memory transfers msgs; do
        for bgm in compute memory transfers msgs none; do
            if [ "$M3_TARGET" = "hw" ]; then
                run_bench "$1" $bw $fgm $bgm
            else
                jobs_submit run_bench "$1" $bw $fgm $bgm
            fi
        done
    done
done

jobs_wait

