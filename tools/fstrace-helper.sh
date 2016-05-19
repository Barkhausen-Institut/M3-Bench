#!/bin/bash

gen_timedtrace() {
    grep -B10000 "===" $1 | grep -v "===" > $1-strace
    grep -A10000 "===" $1 | grep -v "===" | grep -v '^\(random: |Copied|Switched to\)' > $1-timings

    # for untar: prefix relative paths with /tmp/
    sed --in-place -e 's/("\([^/]\)/("\/tmp\/\1/g' $1-strace

    ./tools/timedstrace.php $2 trace $1-strace $1-timings > $1-timedstrace

    # make the strace a little more friendly for strace2cpp
    sed --in-place -e 's/\/\* \([[:digit:]]*\) entries \*\//\1/' $1-timedstrace
    sed --in-place -e 's/\/\* d_reclen == 0, problem here \*\///' $1-timedstrace

    sed -e 's/^ \[\s*\([[:digit:]]*\)\]/\1/g' $1-timings | \
        awk '{ printf "[%3d] %3d %d\n", $1, $2, $4 - $3 }' > $1-timings-human
}

extract_result() {
    awk -v name=$2 'BEGIN {
        start = 0
    }

    END {
        printf("[%s] Total: %d\n", name, end - start)
    }

    # TODO change that to 66 for xtensa
    /^[[:space:]]*\[[[:space:]]*[[:digit:]]+\][[:space:]]*16/ {
        if(start == 0) {
            start = $4
        }
    }

    /^[[:space:]]*\[[[:space:]]*[[:digit:]]+\][[:space:]]*/ {
        end = $4
    }
    ' $1
}
