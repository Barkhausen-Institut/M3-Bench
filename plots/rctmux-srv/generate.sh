#/bin/sh

extract_times() {
    awk '
    BEGIN {
        times["Cli>"] = 0
        times["Fail"] = 0
        times["Wake"] = 0
        times["CtxSw"] = 0
        times["Fwd"] = 0
        times["Call"] = 0
        times["<Cli"] = 0
        count = 0
    }

    /DEBUG.*1ff11234/ {
        p = 1
        indirect = 0
        match($0, /^([[:digit:]]*):/, res)
        start = res[1]
    }

    /pe03.*sd -> (4|5)/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            times["Cli>"] += res[1] - start
            start = res[1]
        }
    }

    /pe03.*sd -> 0/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            times["Fail"] += res[1] - start
            start = res[1]
            indirect = 1
            wakeup = 1
        }
    }

    /pe04.dtu.connector: Waking up core/ {
        if (p && wakeup) {
            match($0, /^([[:digit:]]+):/, res)
            times["Wake"] += res[1] - start
            start = res[1]
            wakeup = 0
        }
    }

    /pe04.*sd -> 0/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            # print("Wait", res[1] - start)
            start = res[1]
        }
    }

    /pe00.*wr -> 4.*f0000000/ {
        if (p) {
            restore = 1
        }
    }

    /pe00.*wr -> 4.*2ff8/ {
        if (p && restore) {
            match($0, /^([[:digit:]]+):/, res)
            times["CtxSw"] += res[1] - start
            start = res[1]
            restore = 0
        }
    }

    /pe00.*sd -> 4/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            times["Fwd"] += res[1] - start
            start = res[1]
        }
    }

    /pe03.*rv <- (4|5)/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            times["Call"] += res[1] - start
            start = res[1]
        }
    }

    /DEBUG.*1ff21234/ {
        match($0, /^([[:digit:]]+):/, res)
        times["<Cli"] += res[1] - start
        count += 1
        p = 0
    }

    END {
        skeys = "Cli>_Fail_Wake_CtxSw_Fwd_Call_<Cli"
        split(skeys, keys, "_")
        for(k in keys) {
            printf "%s %d\n", keys[k], times[keys[k]] / count
        }
    }' $1
}

extract_times $1/m3-rctmux-srv-direct.log | cut -d ' ' -f 2 > $1/m3-rctmux-srv-direct-times.dat
extract_times $1/m3-rctmux-srv-indirect.log > $1/m3-rctmux-srv-indirect-times.dat

echo "Name Indirect Direct" > $1/m3-rctmux-srv-times.dat
paste -d " " $1/m3-rctmux-srv-indirect-times.dat $1/m3-rctmux-srv-direct-times.dat >> \
    $1/m3-rctmux-srv-times.dat

Rscript plots/rctmux-srv/plot.R $1/m3-rctmux-srv.pdf $1/m3-rctmux-srv-times.dat
