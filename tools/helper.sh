#!/bin/bash

reset_bitfile() {
    if [ "$M3_TARGET" = "hw23" ]; then
        ./b loadfpga=fpga_top_v4.6.0.bit -n
    else
        ./b loadfpga=fpga_top_v4.4.12.bit -n
    fi
    # wait a bit until the reset
    sleep 3
}

bench_succeeded() {
    res=$(grep "$3" $2)
    # successful means that the kernel shut down and no program exited with non-zero exitcode
    if [ "$res" != "" ] &&
        [ "$(grep 'Shutting down' $2)" != "" ] &&
        [ "$(grep ' exited with ' $2)" = "" ]; then
        /bin/echo -e "\e[1mFinished $1:\e[0m \e[1;32mSUCCESS\e[0m"
        true
    else
        # reset the bitfile if the kernel didn't start and there was no packet drop. in case of a
        # packet drop, we might succeed next time after a reset.
        /bin/echo -e "\e[1mFinished $1:\e[0m \e[1;31mFAILED\e[0m"
        if [ "$(grep 'detected a UDP packet drop' $2)" == "" ] &&
            [ "$(grep 'Kernel is ready' $2)" = "" ]; then
            reset_bitfile
        fi
        false
    fi
}

rscript_crop() {
    script=$1
    dst=$2
    tmp=${dst/.pdf/.tmp.pdf}
    shift && shift
    if [ "$1" = "--clip" ]; then
        clip=$2
        shift && shift
        Rscript $script $tmp $@ && cp $tmp $dst && pdfcrop --margins "0 0 $clip 0" $tmp $dst
    else
        Rscript $script $tmp $@ && cp $tmp $dst && pdfcrop $tmp $dst
    fi
    rm $tmp
}

get_mhz() {
    ghz=`grep --text 'cpu-clock=' $1 | sed -re 's/.*cpu-clock=([[:digit:]]+)GHz.*/\1/g'`
    if [ "$ghz" != "" ]; then
        echo $(($ghz * 1000))
    else
        grep --text 'cpu-clock=' $1 | sed -re 's/.*cpu-clock=([[:digit:]]+)MHz.*/\1/g'
    fi
}

gen_timedtrace_server() {
    gen_timedtrace $1 $2 --no-ioctl
}

gen_timedtrace_pipe() {
    gen_timedtrace $1 $2 --trace-stdout
}

gen_timedtrace() {
    grep -vE '(^(Copied|Switched to|random: crng))|(^Worker pid:)|(^strace\: Process)' $1 > $1-clean
    grep -B10000 "===" $1-clean | grep -v "===" > $1-strace
    grep -A10000 "===" $1-clean | grep -v "===" > $1-timings

    tmp=`mktemp`
    csplit -s --prefix="$1-timings-" $1-timings /#####/+1 "{*}"
    for f in $1-timings-*; do
        grep -v '#####' $f > $tmp
        cp $tmp $f
    done
    rm $tmp

    # remove "/bench" from absolute paths
    sed --in-place -e 's#"/bench/#"/#g' $1-strace
    # for untar: prefix relative paths with /tmp/
    sed --in-place -e 's/("\([^/]\)/("\/tmp\/\1/g' $1-strace

    ./tools/timedstrace.php trace $1-strace $1-timings-`printf "%02d" $2` $3 > $1-timedstrace

    # make the strace a little more friendly for strace2cpp
    sed --in-place -e 's/\/\* \([[:digit:]]*\) entries \*\//\1/' $1-timedstrace
    sed --in-place -e 's/\/\* d_reclen == 0, problem here \*\///' $1-timedstrace

    sed -e 's/^ \[\s*\([[:digit:]]*\)\]/\1/g' $1-timings-`printf "%02d" $2` | \
        awk '{ printf "[%3d] %3d %d\n", $1, $2, $4 - $3 }' > $1-timings-human
}

gen_results() {
    lxlog=$1/lx-fstrace-$2/res.txt

    lxtota=`./tools/timedstrace.php total $lxlog-strace $lxlog-timings`
    lxxfer=`awk '/Copied/ { print $5 }' $lxlog`
    lxwait=`./tools/timedstrace.php waittime $lxlog-strace $lxlog-timings`

    log=$1/m3-fstrace-$3/gem5.log
    mhz=`get_mhz $1/m3-fstrace-$3/output.txt`

    m3tota=`./m3/src/tools/bench.sh $log $mhz | grep 'TIME: 0000' | ./tools/m3-avg.awk`
    m3xfer=`./m3/src/tools/bench.sh $log $mhz | grep 'TIME: aaaa' | awk '{ sum += $4 } END { print sum }'`
    m3wait=`./m3/src/tools/bench.sh $log $mhz | grep 'TIME: bbbb' | awk '{ sum += $4 } END { print sum }'`

    echo "M3 Lx"
    echo $(($m3tota - $m3xfer - $m3wait)) $(($lxtota - $lxxfer - $lxwait))
    echo $m3xfer $lxxfer
    echo $m3wait $lxwait
}
