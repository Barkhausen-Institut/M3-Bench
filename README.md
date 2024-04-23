This is the benchmark repository for the RTAS'24 paper "Core-Local Reasoning and Predictable Cross-Core Communication with M³". The root repository contains scripts to execute the benchmarks, post process the results, and generate the plots. The submodules `m3`, `bench-lx`, and `NRE` contain M³, Linux, and NOVA+NRE, respectively, including their required infrastructure.

## Hardware requirements

M³ requires a custom hardware platform, which we provide in form of a bitfile for the Xilinx VCU118 FPGA. The bitfile has a static IP address of `192.168.42.240 + N` where `N` is defined by jumpers on the FPGA board. One possible configuration is therefore to have two network cards in the test machine: the first is connected to the Internet, whereas the second is directly connected to the FPGA board.

## Running the benchmarks

Use the following steps to run the benchmarks:

### 1. Build the container

```
docker build -t m3-rtas24 docker
```

### 2. Prepare infrastructure

Start the container and run the `prepare.sh` in it. The container needs the just cloned M3-Bench directory as working directory, mounted at `/m3bench`. Furthermore, it needs access to the Xilinx installation at `/Xilinx` containing Vivado-Lab.

```
XILINX_DIR=... # specify path to Xilinx installation here (contains the `Vivado_Lab` folder)
docker run \
    --net=host \
    -v $(readlink -f .):/m3bench \
    -v $(readlink -f "$XILINX_DIR"):/Xilinx:ro \
    -it m3-rtas24:latest
```

Within the container, execute `./prepare.sh`, which will build the necessary infrastructure for M³, Linux, and NOVA+NRE (cross compilers, FPGA bitfile, etc.):

```
./prepare.sh
```

This step takes about 90 minutes.

### 3. Run the benchmarks

Exit the container as running the benchmarks requires a different network configuration.

First, create a network for the attached FPGA:
```
FPGA_ETH=... # specify the interface name of the NIC attached to the FPGA
docker network create \
    -d macvlan \
    --subnet=192.168.42.0/24 \
    -o parent=$FPGA_ETH \
    fpga
```

Now start container again with access to the FPGA network (and its own loopback device):
```
FPGA_USB_DEV=/dev/bus/usb/... # specify path to USB-attached FPGA device
docker run \
    --net=fpga \
    --device=$FPGA_USB_DEV \
    -v $(readlink -f .):/m3bench \
    -v $(readlink -f "$XILINX_DIR"):/Xilinx:ro \
    -it m3-rtas24:latest
```

Now execute the `run.sh` in the container. This last step will run all benchmarks. The results including all log files etc. are stored in the ``results'' directory. Note that benchmarks on the FPGA will be automatically repeated on failure, because some occasional failures are unavoidable (e.g., sometimes loading programs onto the FPGA fails due to UDP packet drops). Additionally, there are still some hardware/software bugs due to system's complexity that we haven't found yet.

```
./run.sh
```

This step takes about 75 minutes.

## Reproduced results

The benchmarks are used to reproduce the results found in the paper in §V.A, §V.B, §V.C, §V.D, and §V.E. Note however, that the results for L4Re on the R-Car Gen 4 Arm-based SoC and NOVA on the Intel Core i3-8100 used in §V.A are not reproduced, but instead the results are already stored in `plots/rtas23-pingpong` for plot generation.

## Expected results

The raw data we obtained from our own run can be found in the directory `expected-results`. For example, the following commands can be used to compare the results:

```
tail results/*.dat > res.txt
tail expected-results/*.dat > expected.txt
vimdiff res.txt expected.txt
```

However, some results can probably be checked more easily by looking at the generated plots in the `results` directory and comparing them to the plots in `expected-results`.

Note that some benchmarks (the ones on the FPGA and the Linux benchmarks) are not deterministic and thus produce slightly different results each time, while other benchmarks (M³ and NOVA on gem5) are deterministic and thus produce exactly the same results each time.

