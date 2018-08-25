import os, sys

sys.path.append(os.path.realpath('hw/gem5/configs'))
sys.path.append(os.path.realpath('hw/gem5/configs/example'))
from dtu_fs import *

options = getOptions()
root = createRoot(options)

cmd_list = options.cmd.split(",")

num_mem = 1
num_pes = int(os.environ.get('M3_GEM5_PES'))
fsimg = os.environ.get('M3_GEM5_FS')
fsimgnum = os.environ.get('M3_GEM5_FSNUM', '1')
num_fft = int(os.environ.get('ACCEL_NUM'))
num_indir = int(os.environ.get('ACCEL_NUM'))
use_pcie = int(os.environ.get('ACCEL_PCIE')) == 1
mem_pe = num_pes

def pes_range(start, end):
    begin = 0x8000000000000000 + start * 0x0100000000000000
    end = 0x8000000000000000 + (end + 1) * 0x0100000000000000
    return AddrRange(begin, end - 1)

if use_pcie:
    root.noc2 = IOXBar()

    root.bridge_1to2 = Bridge(delay='300ns')
    root.bridge_1to2.master = root.noc2.slave
    root.bridge_1to2.slave = root.noc.master
    root.bridge_1to2.ranges = [pes_range(num_pes + num_mem, num_pes + num_mem + num_indir + num_fft - 1)]

    root.bridge_2to1 = Bridge(delay='300ns')
    root.bridge_2to1.master = root.noc.slave
    root.bridge_2to1.slave = root.noc2.master
    root.bridge_2to1.ranges = [pes_range(0, num_pes + num_mem - 1)]

pes = []

# create the core PEs
for i in range(0, num_pes):
    pe = createCorePE(noc=root.noc,
                      options=options,
                      no=i,
                      cmdline=cmd_list[i],
                      memPE=mem_pe,
                      l1size='32kB',
                      l2size='256kB',
                      dtupos=1,
                      mmu=2)
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pes.append(pe)

# create the memory PEs
for i in range(0, num_mem):
    pe = createMemPE(noc=root.noc,
                     options=options,
                     no=num_pes + i,
                     size='3072MB',
                     image=fsimg if i == 0 else None,
                     imageNum=int(fsimgnum))
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pes.append(pe)

# create the accelerator PEs
options.cpu_clock = '1GHz'

for i in range(0, num_fft):
    pe = createAccelPE(noc=root.noc2 if use_pcie else root.noc,
                       options=options,
                       no=num_pes + num_mem + i,
                       accel='fft',
                       memPE=mem_pe,
                       spmsize='128kB')
                       #l1size='32kB')
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pe.accel.buf_size = '2kB'
    pes.append(pe)

for i in range(0, num_indir):
    pe = createAccelPE(noc=root.noc2 if use_pcie else root.noc,
                       options=options,
                       no=num_pes + num_mem + num_fft + i,
                       accel='indir',
                       memPE=mem_pe,
                       spmsize='128kB')
                       #l1size='32kB')
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pes.append(pe)

runSimulation(root, options, pes)