#!/bin/bash

reset_bitfile() {
    cmd="cd tcu/fpga_tools/testcases/tc_rocket_boot"
    if [ "$M3_HW_FPGA" = "0" ]; then
        # sebastian's FPGA
        cmd="$cmd && source /opt/software/Xilinx/Vivado/2019.1/settings64.sh"
    else
        # mine
        cmd="$cmd && source ~/Applications/Xilinx/Vivado_Lab/2019.1/settings64.sh"
    fi
    cmd="$cmd && BITFILE=\$HOME/tcu/fpga_tools/bitfiles/fpga_top_v4.4.11.bit make program-fpga"
    ssh -t $M3_HW_SSH $cmd
    # wait a bit until the reset
    sleep 5
}

bench_succeeded() {
    res=$(grep "$3" $2)
    # successful means that the kernel shut down and no program exited with non-zero exitcode
    if [ "$res" != "" ] &&
        [ "$(grep 'Shutting down' $2)" != "" ] &&
        [ "$(grep ' exited with ' $2)" = "" ]; then
        /bin/echo -e "\e[1mFinished $1:\e[0m \e[1;32mSUCCESS\e[0m"
        true
    else
        # reset the bitfile if the kernel didn't start and there was no packet drop. in case of a
        # packet drop, we might succeed next time after a reset.
        /bin/echo -e "\e[1mFinished $1:\e[0m \e[1;31mFAILED\e[0m"
        if [ "$(grep 'detected a UDP packet drop' $2)" == "" ] &&
            [ "$(grep 'Kernel is ready' $2)" = "" ]; then
            reset_bitfile
        fi
        false
    fi
}

rscript_crop() {
    script=$1
    dst=$2
    tmp=${dst/.pdf/.tmp.pdf}
    shift && shift
    if [ "$1" = "--clip" ]; then
        clip=$2
        shift && shift
        Rscript $script $tmp $@ && cp $tmp $dst && pdfcrop --margins "0 0 $clip 0" $tmp $dst
    else
        Rscript $script $tmp $@ && cp $tmp $dst && pdfcrop $tmp $dst
    fi
    rm $tmp
}
