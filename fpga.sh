#!/bin/sh

export RUSTUP_HOME=$(readlink -f "$(dirname "$0")")/.rustup
export CARGO_HOME=$(readlink -f "$(dirname "$0")")/.cargo

export LX_HW_SSH=localhost
export M3_HW_FPGA_HOST=localhost
export M3_HW_FPGA_DIR=m3
export M3_HW_FPGA_NO=1
export M3_HW_VIVADO=/Xilinx/Vivado_Lab/2019.1/bin/vivado_lab
export M3_HW_TTY=/dev/ttyUSB2
