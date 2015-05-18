#!/bin/bash

build_source() {
    # don't actually read, but just pretend to do it to measure SW scalability, not HW scalability
    oldread=`grep -m 1 "_lastmem.read_sync" libs/m3/vfs/RegularFile.cc`
    sed --in-place -e 's/_lastmem.read_sync.*/for(volatile int i = 0; i < 40; ++i) ;/' libs/m3/vfs/RegularFile.cc

    # don't actually write, but just pretend to do it to measure SW scalability, not HW scalability
    oldwrite=`grep -m 1 "_lastmem.write_sync" libs/m3/vfs/RegularFile.cc`
    sed --in-place -e 's/_lastmem.write_sync.*/for(volatile int i = 0; i < 40; ++i);/' libs/m3/vfs/RegularFile.cc

    # build everything and undo the changes
    ./b

    logread=$(echo $oldread | sed -e 's/\//\\\//g')
    sed --in-place -e "s/for(volatile int i = 0; i < 40; ++i) ;/$logread/" libs/m3/vfs/RegularFile.cc

    logwrite=$(echo $oldwrite | sed -e 's/\//\\\//g')
    sed --in-place -e "s/for(volatile int i = 0; i < 40; ++i);/$logwrite/" libs/m3/vfs/RegularFile.cc
}

run_scripts() {
    name=$1
    generator=$2
    scripts=""
    for par in $parallel; do
        script=`mktemp --suffix -$name-$par.cfg`
        scr[$par]=$script
        chmod +x $script

        $generator $par > $script

        scripts="$scripts $script"
    done
    ./tools/t3bench.sh $scripts
}

extract_results() {
    echo 'Title Operation Setup' > $dat
    for par in $parallel; do
        script=${scr[$par]}
        result=bench/`basename $script`
        echo -n $par >> $dat
        echo -n " `grep 0001 $result | ./tools/extract-results.awk`" >> $dat
        echo -n " `grep 0000 $result | ./tools/extract-results.awk`" >> $dat
        echo >> $dat
        rm $script $result
    done
}

generate_plot() {
    input=$1
    output=$2
    title=$3
    maxy=$4
    script=`mktemp`
    cat > $script <<'EOF'
reset
col1 = "#159027"; col2 = "#c11b1b"; col3 = "#b3aa5"; col4 = "#ffb000"; col5 = "#7f3fb6"; col6 = "#3f81b6"
set auto x
set yrange [0:maxy]
set style data histogram
set style histogram rowstacked
set style fill solid
set boxwidth 0.9
set grid ytics
set xtic scale 0
set key left top
set ylabel 'Time (cycles)'
set xlabel '# Applications'
set title title

plot input_file using \
    2:xtic(1) ti col fc rgb col1, \
    '' u 4 ti col fc rgb col2

set terminal postscript enhance eps size 3.8,2 14 linewidth 1
set output output_file
replot
EOF

    gnuplot \
        -e "input_file='$input'" \
        -e "output_file='$output'" \
        -e "title='$title'" \
        -e "maxy='$maxy'" \
        $script
    rm $script
}
