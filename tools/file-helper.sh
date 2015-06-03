#!/bin/bash

build_source() {
    # don't actually read, but just pretend to do it to measure SW scalability, not HW scalability
    oldread=`grep -m 1 "_lastmem.read_sync" libs/m3/vfs/RegularFile.cc`
    sed --in-place -e 's/_lastmem.read_sync.*/for(volatile int i = 0; i < 26; ++i) ;/' libs/m3/vfs/RegularFile.cc

    # don't actually write, but just pretend to do it to measure SW scalability, not HW scalability
    oldwrite=`grep -m 1 "_lastmem.write_sync" libs/m3/vfs/RegularFile.cc`
    sed --in-place -e 's/_lastmem.write_sync.*/for(volatile int i = 0; i < 26; ++i);/' libs/m3/vfs/RegularFile.cc

    # build everything and undo the changes
    ./b

    logread=$(echo $oldread | sed -e 's/\//\\\//g')
    sed --in-place -e "s/for(volatile int i = 0; i < 26; ++i) ;/$logread/" libs/m3/vfs/RegularFile.cc

    logwrite=$(echo $oldwrite | sed -e 's/\//\\\//g')
    sed --in-place -e "s/for(volatile int i = 0; i < 26; ++i);/$logwrite/" libs/m3/vfs/RegularFile.cc
}

run_scripts() {
    t3par=$1
    result=$2
    name=$3
    generator=$4
    scripts=""
    for par in $parallel; do
        script=$result$name-$par.cfg
        scr[$par]=$script

        $generator $par > $script
        chmod +x $script

        scripts="$scripts $script"
    done
    ( $t3par $result $scripts )
}

extract_results() {
    dat=$1
    echo 'Title Operation Setup' > $dat
    for par in $parallel; do
        script=${scr[$par]}-result.txt
        echo -n $par >> $dat
        echo -n " `grep 0001 $script | ./tools/m3-avg.awk`" >> $dat
        echo -n " `grep 0000 $script | ./tools/m3-avg.awk`" >> $dat
        echo >> $dat
    done
}
