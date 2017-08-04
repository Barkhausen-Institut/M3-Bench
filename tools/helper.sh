#!/bin/bash

get_mhz() {
    ghz=`grep 'cpu-clock=' $1 | sed -re 's/.*cpu-clock=([[:digit:]]+)GHz.*/\1/g'`
    if [ "$ghz" != "" ]; then
        echo $(($ghz * 1000))
    else
        grep 'cpu-clock=' $1 | sed -re 's/.*cpu-clock=([[:digit:]]+)MHz.*/\1/g'
    fi
}

gen_timedtrace() {
    grep -vE '^(Copied|Switched to)' $1 > $1-clean
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

    ./tools/timedstrace.php trace $1-strace $1-timings-07 > $1-timedstrace

    # make the strace a little more friendly for strace2cpp
    sed --in-place -e 's/\/\* \([[:digit:]]*\) entries \*\//\1/' $1-timedstrace
    sed --in-place -e 's/\/\* d_reclen == 0, problem here \*\///' $1-timedstrace

    sed -e 's/^ \[\s*\([[:digit:]]*\)\]/\1/g' $1-timings-07 | \
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
