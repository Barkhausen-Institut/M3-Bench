#!/bin/bash

. tools/helper.sh

cd m3 || exit 1

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_SSH=bitest M3_HW_FPGA=1
export M3_HW_RESET=1
export M3_HW_TIMEOUT=120

./b || exit 1

tmpdir=$(mktemp -d)
trap 'rm -rf -- "$tmpdir"' EXIT

run_bench() {
    fgm=$2
    bgm=$3
    dirname=m3-disturb-$fgm-$bgm
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    cfg="$tmpdir/disturb-$fgm-$bgm.xml"
    gen_config "$fgm" "$bgm" > "$cfg"

    i=0
    while [ $i -lt 2 ]; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        ./b run "$cfg" -n > "$M3_OUT/output.txt" 2>&1

        if [ $? -eq 0 ] && [ "$(grep 'Shutting down' "$M3_OUT/output.txt")" != "" ]; then
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
            break
        else
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;31mFAILED\e[0m"
            # if the kernel didn't start, we assume that there is something fundamentally wrong and
            # therefore reinstall the bitfile.
            if [ "$(grep 'Kernel is ready' "$M3_OUT/output.txt")" = "" ]; then
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
    fgmode=$1
    bgmode=$2

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
                    echo "            <dom tile=\"boom+nic\">"
                else
                    echo "            <dom>"
                fi
                echo "                <app args=\"memload $bgmode 100000\" daemon=\"1\">"
                echo "                </app>"
                echo "            </dom>"
                i=$((i + 1))
            else
                echo "            <dom>"
                echo "                <app args=\"ppsender 100000 0 2032 0\">"
                echo "                    <sgate lname=\"chan\" gname=\"chan$i\" label=\"1\" />"
                echo "                    <sem lname=\"ready\" gname=\"ready$i\" />"
                echo "                </app>"
                echo "            </dom>"
                if [ $((i + 2)) -ge $others ]; then
                    echo "            <dom tile=\"boom+nic\">"
                else
                    echo "            <dom>"
                fi
                echo "                <app args=\"ppreceiver 100000 2032\">"
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
        echo "                <app args=\"memload $fgmode 100\">"
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

for fgm in compute memory transfers msgs; do
    for bgm in compute memory transfers msgs none; do
        run_bench "$1" $fgm $bgm
    done
done
