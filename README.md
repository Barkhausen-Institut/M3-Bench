This is the benchmark repository for the RTAS'24 paper "Core-Local Reasoning and Predictable
Cross-Core Communication with M³". The root repository contains scripts to execute the benchmarks,
post process the results, and generate the plots. The submodules `m3`, `bench-lx`, and `NRE` contain
M³, Linux, and NOVA+NRE, respectively, including their required infrastructure.

## Warning

As some experiments are done with an FPGA, only *one reviewer* can do the artifact evaluation at a
time! We recommend to check whether the `M3-Bench` directory already exists before starting, try
again later if it does, and removing this directory after you are done with your evaluation.

## Running the benchmarks

Use the following steps to run the benchmarks:

### 1. Clone the respository

```
git clone https://github.com/Barkhausen-Institut/M3-Bench.git --branch rtas24
cd M3-Bench
```

### 2. Prepare infrastructure

The preparation step will build the necessary infrastructure for M³, Linux, and NOVA+NRE (cross
compilers, FPGA bitfile, etc.). Just execute the `prepare.sh`:

```
./prepare.sh
```

This step takes about 90 minutes.

### 3. Run the benchmarks

This last step will run all benchmarks. The results including all log files etc. are stored in the
``results'' directory. Note that benchmarks on the FPGA will be automatically repeated on failure,
because some occasional failures are unavoidable (e.g., sometimes loading programs onto the FPGA
fails due to UDP packet drops). Additionally, there are still some hardware/software bugs due to
system's complexity that we haven't found yet.

```
./run.sh
```

This step takes about 75 minutes.

## Reproduced results

The benchmarks are used to reproduce the results found in the paper in §V.A, §V.B, §V.C, §V.D, and
§V.E. Note however, that the results for L4Re on the R-Car Gen 4 Arm-based SoC and NOVA on the Intel
Core i3-8100 used in §V.A are not reproduced, but instead the results are already stored in
`plots/rtas23-pingpong` for plot generation.

## Expected results

The raw data we obtained from our own run can be found in the directory `expected-results`. For
example, the following commands can be used to compare the results:

```
tail results/*.dat > res.txt
tail expected-results/*.dat > expected.txt
vimdiff res.txt expected.txt
```

However, some results can probably be checked more easily by looking at the generated plots in the
`results` directory and comparing them to the plots in `expected-results`.

Note that some benchmarks (the ones on the FPGA and the Linux benchmarks) are not deterministic and
thus produce slightly different results each time, while other benchmarks (M³ and NOVA on gem5) are
deterministic and thus produce exactly the same results each time.
