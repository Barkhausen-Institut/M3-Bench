import os, sys

sys.path.append(os.path.realpath('hw/gem5/configs'))
sys.path.append(os.path.realpath('hw/gem5/configs/example'))
from dtu_fs import *

options = getOptions()
root = createRoot(options)

cmd_list = options.cmd.split(",")

ala = ['test_stencil', 'test_md', 'test_spmv', 'test_fft']
num_mem = 1
num_pes = int(os.environ.get('M3_GEM5_PES'))
num_accels = len(ala)
use_pcie = int(os.environ.get('ACCEL_PCIE')) == 1
fsimg = os.environ.get('M3_GEM5_FS')
fsimgnum = os.environ.get('M3_GEM5_FSNUM', '1')
dtupos = int(os.environ.get('M3_GEM5_DTUPOS', 0))
mmu = int(os.environ.get('M3_GEM5_MMU', 0))
mem_pe = num_pes + len(ala)

def pes_range(start, end):
    begin = 0x8000000000000000 + start * 0x0100000000000000
    end = 0x8000000000000000 + (end + 1) * 0x0100000000000000
    return AddrRange(begin, end - 1)

if use_pcie:
    root.noc2 = IOXBar()

    root.bridge_1to2 = Bridge(delay='300ns')
    root.bridge_1to2.master = root.noc2.slave
    root.bridge_1to2.slave = root.noc.master
    root.bridge_1to2.ranges = [pes_range(num_pes + num_mem, num_pes + num_mem + num_accels - 1)]

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
                      dtupos=dtupos,
                      mmu=mmu == 1)
    pes.append(pe)

options.cpu_clock = '1GHz'

# create ALADDIN accelerators
for i in range(0, len(ala)):
    pe = createAladdinPE(noc=root.noc2 if use_pcie else root.noc,
                         options=options,
                         no=num_pes + i,
                         accel=ala[i],
                         memPE=mem_pe,
                         l1size='32kB')
    pes.append(pe)

# create the memory PEs
for i in range(0, num_mem):
    pe = createMemPE(noc=root.noc,
                     options=options,
                     no=num_pes + len(ala) + i,
                     size='3072MB',
                     image=fsimg if i == 0 else None,
                     imageNum=int(fsimgnum))
    pes.append(pe)

runSimulation(root, options, pes)
