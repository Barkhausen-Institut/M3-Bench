#!/bin/bash

. tools/helper.sh

mhz=`get_mhz $1/m3-aladdin-fft-0-anon/output.txt`

get_comp_times() {
    awk -v mhz=1000 '
        /DEBUG 0x1ff11234/ {
            match($1, /^([[:digit:]]+):/, m)
        }

        /rv <- 4.*EP7/ {
            match($1, /^([[:digit:]]+):/, m)
            if(num >= 1) {
                start=m[1]
            }
        }

        /rp -> 4.*EP7/ {
            match($1, /^([[:digit:]]+):/, m)
            if(num >= 1) {
                times[i] = m[1] - start
                i += 1
            }
        }

        /DEBUG 0x1ff21234/ {
            match($1, /^([[:digit:]]+):/, m)
            num += 1
        }

        function stddev(vals, avg) {
            sum = 0
            for(v in vals) {
                sum += (vals[v] - avg) * (vals[v] - avg)
            }
            return sqrt(sum / length(vals))
        }

        function ticksToCycles(ticks) {
            return ticks * (mhz / 1000000)
        }

        END {
            sum = 0
            max = 0
            n = 0
            for(t in times) {
                sum += times[t]
                if(times[t] > max)
                    max = times[t]
                n += 1
            }
            printf("%u %u\n",
                ticksToCycles(sum / n),
                ticksToCycles(max))
        }
    ' < $1
}

get_times() {
    for s in 1 4 16 64 256 0; do
        time=`./tools/m3-bench.sh time 1234 $mhz 1 < $1/m3-aladdin-$2-$s-$3/gem5.log`
        echo $time
    done
}

for b in stencil md fft spmv; do
    echo "Generating times for $b-file..."
    get_times $1 $b file > $1/$b-file-times.dat
    echo "Generating times for $b-anon..."
    get_times $1 $b anon > $1/$b-anon-times.dat
done

for b in stencil md fft spmv; do
    echo -n > $1/$b-anon-comptimes.dat
    echo -n > $1/$b-anon-compmax.dat
    echo -n > $1/$b-file-comptimes.dat
    echo -n > $1/$b-file-compmax.dat
    for s in 1 4 16 64 256 0; do
        echo "Generating compute times for $b-$s-anon..."
        anon=`get_comp_times $1/m3-aladdin-$b-$s-anon/gem5.log`
        echo $anon | cut -d ' ' -f 1 >> $1/$b-anon-comptimes.dat
        echo $anon | cut -d ' ' -f 2 >> $1/$b-anon-compmax.dat

        echo "Generating compute times for $b-$s-file..."
        file=`get_comp_times $1/m3-aladdin-$b-$s-file/gem5.log`
        echo $file | cut -d ' ' -f 1 >> $1/$b-file-comptimes.dat
        echo $file | cut -d ' ' -f 2 >> $1/$b-file-compmax.dat
    done
done

for t in file anon; do
    rscript_crop plots/diss-accel-aladdin/plot-total.R $1/eval-accel-aladdin-$t.pdf \
        $1/stencil-$t-times.dat \
        $1/md-$t-times.dat \
        $1/fft-$t-times.dat \
        $1/spmv-$t-times.dat

    rscript_crop plots/diss-accel-aladdin/plot-comp.R $1/eval-accel-aladdin-$t-comp.pdf \
        $1/stencil-$t-comptimes.dat $1/stencil-$t-compmax.dat \
        $1/md-$t-comptimes.dat $1/md-$t-compmax.dat \
        $1/fft-$t-comptimes.dat $1/fft-$t-compmax.dat \
        $1/spmv-$t-comptimes.dat $1/spmv-$t-compmax.dat
done
