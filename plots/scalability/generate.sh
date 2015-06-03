#!/bin/bash

gnuplot \
    -e "input_file='$1/filereader.dat'" \
    -e "output_file='$1/filereader.pdf'" \
    -e "title='Time for reading a 2MB file from the FS'" \
    -e "maxy='400000'" \
    plots/scalability/plot.script

gnuplot \
    -e "input_file='$1/filewriter.dat'" \
    -e "output_file='$1/filewriter.pdf'" \
    -e "title='Time for creating a 2MB file'" \
    -e "maxy='700000'" \
    plots/scalability/plot.script
