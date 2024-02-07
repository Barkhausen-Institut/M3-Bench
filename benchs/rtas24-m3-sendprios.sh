#!/bin/bash

source tools/helper.sh

cd m3 || exit 1

export M3_BUILD=release
export M3_TARGET=hw M3_ISA=riscv
export M3_HW_VM=1 M3_HW_RESET=1
export M3_HW_TIMEOUT=30

./b || exit 1

tmpdir=$(mktemp -d)
trap 'rm -rf -- "$tmpdir"' EXIT

run_bench() {
    clients=$2
    prios=$3
    dirname=m3-sendprios-hw-$clients-$prios
    export M3_OUT=$1/$dirname
    mkdir -p "$M3_OUT"

    cfg="$tmpdir/disturb-$clients-$prios.xml"
    gen_config "$clients" "$prios" > "$cfg"

    while true; do
        /bin/echo -e "\e[1mStarting $dirname\e[0m"

        ./b run "$cfg" -n &> "$M3_OUT/output.txt"

        sed --in-place -e 's/\x1b\[0m//g' "$M3_OUT/output.txt"

        # workaround for not terminating senders on some tiles; just check whether the results are there
        if [ "$(grep -c "PERF" "$M3_OUT/output.txt")" -eq "$clients" ]; then
            /bin/echo -e "\e[1mFinished $dirname:\e[0m \e[1;32mSUCCESS\e[0m"
            break
        fi
        if bench_succeeded "$dirname" "$M3_OUT/output.txt" 'PERF'; then
            break
        fi
    done
}

gen_config() {
    clients=$1
    prios=$2

    reqtime=1000
    c1slots=$clients
    c2slots=$clients
    postwait=0
    runs=1000
    warmup=10

    echo "<config>"
    echo "<kernel args=\"kernel\" />"
    echo "<dom>"
    echo "    <app args=\"root maxcli=$((clients + 1)) sem=ready\">"
    echo "        <app args=\"prioreceiver $clients $prios $reqtime\" daemon=\"1\">"
    echo "            <rgate name=\"chan1\" msgsize=\"64\" slots=\"$c1slots\" />"
    echo "            <rgate name=\"chan2\" msgsize=\"64\" slots=\"$c2slots\" />"
    echo "            <sem name=\"ready\" />"
    echo "        </app>"
    echo "        <dom>"
    echo "            <app args=\"priosender 1 $runs $warmup $postwait 1\">"
    echo "                <sgate name=\"chan1\" label=\"1\" />"
    echo "                <sem name=\"ready\" />"
    echo "            </app>"
    echo "        </dom>"
    n=1
    while [ $n -lt "$clients" ]; do
        if [ "$prios" -eq 2 ]; then
            prio=2
        else
            prio=1
        fi
        echo "        <dom>"
        echo "            <app args=\"priosender $prio $runs $warmup 0 1\">"
        echo "                <sgate name=\"chan$prio\" label=\"2\" credits=\"1\" />"
        echo "                <sem name=\"ready\" />"
        echo "            </app>"
        echo "        </dom>"
        n=$((n + 1))
    done

    echo "    </app>"
    echo "</dom>"
    echo "</config>"
}

for c in {1..6}; do
    run_bench "$1" "$c" 1
    run_bench "$1" "$c" 2
done
