#/bin/sh

extract_times() {
    awk '
    /DEBUG.*1ff11234/ {
        p = 1
        indirect = 0
        match($0, /^([[:digit:]]*):/, res)
        start = res[1]
    }

    /pe03.*sd -> (4|5)/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            print("Cli>", res[1] - start)
            start = res[1]
        }
    }

    /pe03.*sd -> 0/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            print("Fail", res[1] - start)
            start = res[1]
            indirect = 1
            wakeup = 1
        }
    }

    /pe04.dtu.connector: Waking up core/ {
        if (p && wakeup) {
            match($0, /^([[:digit:]]+):/, res)
            print("Wake", res[1] - start)
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
            print("CtxSw", res[1] - start)
            start = res[1]
            restore = 0
        }
    }

    /pe00.*sd -> 4/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            print("Fwd", res[1] - start)
            start = res[1]
        }
    }

    /pe03.*rv <- (4|5)/ {
        if (p) {
            match($0, /^([[:digit:]]+):/, res)
            if (!indirect) {
                print("Fail", 0)
                print("Wake", 0)
                print("Wait", 0)
                print("CtxSw", 0)
                print("Fwd", 0)
            }
            print("Call", res[1] - start)
            start = res[1]
        }
    }

    /DEBUG.*1ff21234/ {
        match($0, /^([[:digit:]]+):/, res)
        print("<Cli", res[1] - start)
        p = 0
    }' $1
}

extract_times $1/m3-rctmux-srv-direct.log | tail -7 > $1/m3-rctmux-srv-direct-times.dat
extract_times $1/m3-rctmux-srv-indirect.log | tail -7 | cut -d ' ' -f 2 > $1/m3-rctmux-srv-indirect-times.dat

echo "Name Direct Indirect" > $1/m3-rctmux-srv-times.dat
paste -d " " $1/m3-rctmux-srv-direct-times.dat $1/m3-rctmux-srv-indirect-times.dat >> \
    $1/m3-rctmux-srv-times.dat

Rscript plots/rctmux-srv/plot.R $1/m3-rctmux-srv.pdf $1/m3-rctmux-srv-times.dat
