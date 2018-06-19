import os, sys

sys.path.append(os.path.realpath('hw/gem5/configs'))
sys.path.append(os.path.realpath('hw/gem5/configs/example'))
from dtu_fs import *

options = getOptions()
root = createRoot(options)

cmd_list = options.cmd.split(",")

num_mem = 1
num_pes = int(os.environ.get('M3_GEM5_PES'))
num_accels = int(os.environ.get('ACCEL_NUM'))
fsimg = os.environ.get('M3_GEM5_FS')
dtupos = int(os.environ.get('M3_GEM5_DTUPOS', 0))
mmu = int(os.environ.get('M3_GEM5_MMU', 0))
mem_pe = num_pes + num_accels

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
for i in range(0, num_accels):
    pe = createAladdinPE(noc=root.noc,
                         options=options,
                         no=num_pes + i,
                         accel='test_stencil',
                         memPE=mem_pe,
                         l1size='32kB')
    pes.append(pe)

# create the memory PEs
for i in range(0, num_mem):
    pe = createMemPE(noc=root.noc,
                     options=options,
                     no=num_pes + num_accels + i,
                     size='1024MB',
                     content=fsimg if i == 0 else None)
    pes.append(pe)

runSimulation(root, options, pes)
