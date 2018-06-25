#!/bin/zsh

get_result() {
    aloneeff=$2
    shareeff=$3
    n=$4
    aloneno=$5
    shareno=$6

    if [[ $aloneeff -gt $shareeff ]]; then
        echo -n $aloneeff >> $1/eval-app-efficiency.dat
        echo -n $aloneno >> $1/eval-app-pes.dat
    else
        echo -n $shareeff >> $1/eval-app-efficiency.dat
        echo -n $shareno >> $1/eval-app-pes.dat
    fi
    if [ $n -eq 16 ]; then
        echo -n " " >> $1/eval-app-efficiency.dat
        echo -n " " >> $1/eval-app-pes.dat
    fi
}

echo -n > $1/eval-app-efficiency.dat
echo -n > $1/eval-app-pes.dat

i=1
for tr in tar untar find sqlite leveldb sha256sum sort; do
    echo "Generating efficiency of $tr..."
    echo -n "$tr " >> $1/eval-app-efficiency.dat
    echo -n "$tr " >> $1/eval-app-pes.dat

    for n in 16 32; do
        if [ $n -eq 16 ]; then
            col=5
            row=6
        else
            col=6
            row=7
        fi

        alone=`sed -n "$row,$row p" $1/app-scale-$tr.dat`
        aloneeff=0
        aloneno=0
        for x in 0 1 2 3; do
            appeff=`echo $alone | awk "{ print($"$(($x + 1))") }"`
            if [ "$appeff" = "NA" ]; then
                continue
            fi
            # kernel + pager + $n * apps + 2^$x * m3fs
            appeff=$((($n * $appeff) / (1 + 1 + $n + 2 ** $x)))
            if [[ $appeff -gt $aloneeff ]]; then
                aloneeff=$appeff
                aloneno=$((1 + 1 + $n + 2 ** $x))
            fi
        done

        share=`sed -n "$i,$i p" $1/app-scale-ctx.dat | awk '{ print($'$col') }'`
        if [ "$share" = "NA" ]; then
            share=0
        fi
        # kernel + apps
        shareeff=$((($share * $n) / (1 + $n)))

        get_result $1 $aloneeff $shareeff $n $aloneno $((1 + $n))
    done

    echo >> $1/eval-app-efficiency.dat
    echo >> $1/eval-app-pes.dat
    i=$(($i + 1))
done

i=2
for tr in cat-wc cat-awk grep-wc grep-awk; do
    echo "Generating efficiency of $tr..."
    echo -n "$tr " >> $1/eval-app-efficiency.dat
    echo -n "$tr " >> $1/eval-app-pes.dat

    for n in 16 32; do
        if [ $n -eq 16 ]; then
            col=4
        else
            col=5
        fi

        alone=`sed -n "$i,$i p" $1/pipe-scale-0.dat | awk "{ print($"$col") }"`
        # kernel + $n * apps + pager + pipeserv + m3fs
        aloneeff=$((($n * $alone) / (1 + $n + 3)))

        share=`sed -n "$i,$i p" $1/pipe-scale-1.dat | awk "{ print($"$col") }"`
        # kernel + $n * apps
        shareeff=$((($n * $share) / (1 + $n)))

        get_result $1 $aloneeff $shareeff $n $((1 + $n + 3)) $((1 + $n))
    done

    echo >> $1/eval-app-efficiency.dat
    echo >> $1/eval-app-pes.dat
    i=$(($i + 1))
done

sed --in-place -e 's/sha256sum/shasum/g' $1/eval-app-efficiency.dat
sed --in-place -e 's/sha256sum/shasum/g' $1/eval-app-pes.dat
