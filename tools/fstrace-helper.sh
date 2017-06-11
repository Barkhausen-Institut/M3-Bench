#!/bin/bash

gen_timedtrace() {
    grep -B10000 "===" $1 | grep -v "===" > $1-strace
    grep -A10000 "===" $1 | grep -v "===" | grep -v '^\(random: |Copied|Switched to\)' > $1-timings

    # remove "/bench" from absolute paths
    sed --in-place -e 's#"/bench/#"/#g' $1-strace
    # for untar: prefix relative paths with /tmp/
    sed --in-place -e 's/("\([^/]\)/("\/tmp\/\1/g' $1-strace

    ./tools/timedstrace.php trace $1-strace $1-timings > $1-timedstrace

    # make the strace a little more friendly for strace2cpp
    sed --in-place -e 's/\/\* \([[:digit:]]*\) entries \*\//\1/' $1-timedstrace
    sed --in-place -e 's/\/\* d_reclen == 0, problem here \*\///' $1-timedstrace

    sed -e 's/^ \[\s*\([[:digit:]]*\)\]/\1/g' $1-timings | \
        awk '{ printf "[%3d] %3d %d\n", $1, $2, $4 - $3 }' > $1-timings-human
}

gen_results() {
    lxlog=$1/lx-fstrace-$2/res.txt

    lxtota=`./tools/timedstrace.php total $lxlog-strace $lxlog-timings`
    lxxfer=`awk '/Copied/ { print $5 }' $lxlog`
    lxwait=`./tools/timedstrace.php waittime $lxlog-strace $lxlog-timings`

    log=$1/m3-fstrace-$2/gem5.log

    m3tota=`./m3/src/tools/bench.sh $log | grep 'TIME: 0000' | ./tools/m3-avg.awk`
    m3xfer=`./m3/src/tools/bench.sh $log | grep 'TIME: aaaa' | awk '{ sum += $4 } END { print sum }'`
    m3wait=`./m3/src/tools/bench.sh $log | grep 'TIME: bbbb' | awk '{ sum += $4 } END { print sum }'`

    echo "M3 Lx"
    echo $(($m3tota - $m3xfer - $m3wait)) $(($lxtota - $lxxfer - $lxwait))
    echo $m3xfer $lxxfer
    echo $m3wait $lxwait
}
