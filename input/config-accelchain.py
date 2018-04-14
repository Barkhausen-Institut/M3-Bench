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
num_fft = 6
num_indir = 6
mem_pe = num_pes + num_fft + num_indir

pes = []

# create the core PEs
options.cpu_clock = '3GHz'
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
    pes.append(pe)

for i in range(0, num_fft):
    pe = createAccelPE(noc=root.noc,
                       options=options,
                       no=num_pes + i,
                       accel='fft',
                       memPE=mem_pe,
                       spmsize='128kB')
                       #l1size='32kB')
    pes.append(pe)

for i in range(0, num_indir):
    pe = createAccelPE(noc=root.noc,
                       options=options,
                       no=num_pes + num_fft + i,
                       accel='indir',
                       memPE=mem_pe,
                       spmsize='128kB')
                       #l1size='32kB')
    pes.append(pe)

# create the memory PEs
for i in range(0, num_mem):
    pe = createMemPE(noc=root.noc,
                     options=options,
                     no=num_pes + num_fft + num_indir + i,
                     size='1024MB',
                     content=fsimg if i == 0 else None)
    pes.append(pe)

runSimulation(root, options, pes)
