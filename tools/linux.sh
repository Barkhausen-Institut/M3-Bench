#!/bin/sh

get_line() {
    php -- $1 $2 <<'EOF'
<?php
$i = 0;
$indices = array();
$indices['IDX_SYSCALL'] =             $i++;
$indices['IDX_TASKCRT'] =             $i++;
$indices['IDX_PTHREAD'] =             $i++;
$indices['IDX_CLONE'] =               $i++;
$indices['IDX_FORK'] =                $i++;
$indices['IDX_EXEC'] =                $i++;
$indices['IDX_VEXEC'] =               $i++;
$indices['IDX_READ'] =                $i++;
$indices['IDX_READ_MEMCPY'] =         $i++;
$indices['IDX_READ_MMAP'] =           $i++;
$indices['IDX_READ_MMAP_AGAIN'] =     $i++;
$indices['IDX_READ_MMAP_CP'] =        $i++;
$indices['IDX_READ_MMAP_CP_AGAIN'] =  $i++;
$indices['IDX_CHKSUM_READ'] =         $i++;
$indices['IDX_CHKSUM_READ_MEMCPY'] =  $i++;
$indices['IDX_CHKSUM_MMAP'] =         $i++;
$indices['IDX_CHKSUM_MMAP_AGAIN'] =   $i++;
$indices['IDX_WRITE'] =               $i++;
$indices['IDX_WRITE_MEMCPY'] =        $i++;
$indices['IDX_COPY_RDWR'] =           $i++;
$indices['IDX_COPY_RDWR_MEMCPY'] =    $i++;
$indices['IDX_COPY_MMAP'] =           $i++;
$indices['IDX_COPY_MMAP_AGAIN'] =     $i++;
$indices['IDX_PIPE'] =                $i++;
$indices['IDX_PIPE_MEMCPY'] =         $i++;

$lines = file($argv[1]);
echo $lines[$indices[$argv[2]]];
?>
EOF
}

cache_misses() {
    # we have run it once with 13 cycles for M and once with 30 cycles.
    # thus, the equations are:
    # $ai = 1 * C + 13 * n
    # $bi = 1 * C + 30 * n
    # the right side is the matrix [1, 13; 1, 30].
    # we solve it by dividing it by [$ai; $bi] and take the second element to get C (opposite order)

    val=`octave -q --eval "A = [1, 13; 1, 30]; b = [$1; $2]; x = A \ b; round(nth_element(x, 2))" | awk '{ print $3 }'`
    if [ $val -lt $2 ]; then
        echo $(($2 - $val))
    else
        echo 0
    fi
}

lx_avg() {
    get_line $1 $2 | cut -d ':' -f 2 | awk '{ printf "%d", $1 }'
}

lx_stddev() {
    # tr to remove the \r
    get_line $1 $2 | cut -d ':' -f 2 | sed -e 's/[^\(]*(\([[:digit:]]*\))/\1/' | tr -d '[[:space:]]'
}

lx_rem_time() {
    lx30=`lx_avg $1/lx-30cycles.txt "$2"`
    lx13=`lx_avg $1/lx-13cycles.txt "$2"`
    lx30mc=`lx_avg $1/lx-30cycles.txt "$3"`
    lx13mc=`lx_avg $1/lx-13cycles.txt "$3"`
    rem30=$(($lx30 - $lx30mc))
    rem13=$(($lx13 - $lx13mc))
    cm=`cache_misses $rem13 $rem30`
    echo $rem30 $(($rem13 - $cm))
}

lx_copy_time() {
    lx30=`lx_avg $1/lx-30cycles.txt "$2"`
    lx30mc=`lx_avg $1/lx-30cycles.txt "$3"`
    lx13mc=`lx_avg $1/lx-13cycles.txt "$3"`
    cm=`cache_misses $lx13mc $lx30mc`
    echo $lx30mc $(($lx30mc - $cm))
}

lx_times() {
    lx30=`lx_avg $1/lx-30cycles.txt "$2"`
    lx13=`lx_avg $1/lx-13cycles.txt "$2"`
    cm=`cache_misses $lx13 $lx30`
    echo $(($lx30 - $cm)) $cm
}
