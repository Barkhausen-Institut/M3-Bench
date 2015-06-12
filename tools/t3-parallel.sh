#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: $0 <result> <boot-script>..."
    exit 1
fi

build=build/$M3_TARGET-$M3_MACHINE-$M3_BUILD
result=$1
shift

cleanup() {
    sed --in-place -e "s/log4xtensa.appender.file.File=.*/log4xtensa.appender.file.File=xtsc.log/g" ../TextLogger.txt
}

# enable job control
set -m
trap "cleanup" EXIT

declare -A logs
declare -A jids

i=0
for b in $@; do
    # set log-file to a temporary file
    log=$result$(basename $b)-log.txt
    logs[$b]=$log
    fifo=$result$(basename $b).fifo
    rm -f $fifo
    fifosed=$(echo $fifo | sed -e 's/\//\\\//g')
    sed --in-place -e "s/log4xtensa.appender.file.File=.*/log4xtensa.appender.file.File=$fifosed/g" ../TextLogger.txt

    # start filter
    ./$build/tools/logfilter/logfilter $fifo > $log &

    # start and remember job-id
    echo "Starting `basename $b` (logging to `basename $log`)..."
    M3_FS=bench.img M3_NOTRACE=1 ./b run $b -n >$log-stdout 2>&1 &

    # we assume here that job ids are 1...n
    i=$((i+2))
    jids[$b]=$i

    # wait a bit to give the simulator the chance to read ../TextLogger.txt
    sleep 1
done

# ignore the filter-jobs
i=$((i/2))

# show progress of jobs
while true; do
    c=0
    for b in $@; do
        # if the job still exists
        if jobs ${jids[$b]} >/dev/null 2>&1; then
            printf "%-20s: " $b
            # extract current cycle-counter. take care that the file may still be empty
            if [ `stat --format=%s ${logs[$b]}` -eq 0 ]; then
                printf "starting\n";
            else
                tail -n 1 ${logs[$b]} | awk '{ print $4 }' | \
                    sed -e 's/\([[:digit:]]*\)\..*/\1 cycles        /'
            fi
            c=$((c+1))
        else
            printf "%-20s: done             \n" $b
        fi
    done

    # all jobs done?
    if [ $c -eq 0 ]; then
        break
    fi

    # move $i (number of jobs) lines upwards
    /bin/echo -e -n "\r\033["$i"A"
    sleep 2
done

# extract results
for b in $@; do
    res=$result$(basename $b)-result.txt
    echo "Storing result of `basename $b` to `basename $res`"
    ./tools/bench.sh ${logs[$b]} > $res
done

cleanup
