import os, sys

sys.path.append(os.path.realpath('hw/gem5/configs'))
sys.path.append(os.path.realpath('hw/gem5/configs/example'))
from dtu_fs import *

options = getOptions()
root = createRoot(options)

cmd_list = options.cmd.split(",")

num_pes = int(os.environ.get('M3_GEM5_PES'))
fsimg = os.environ.get('M3_GEM5_FS')
mem_pe = num_pes

pes = []

# create the core PEs
for i in range(0, num_pes):
    pe = createCorePE(root=root,
                      options=options,
                      no=i,
                      cmdline=cmd_list[i],
                      memPE=mem_pe,
                      l1size='64kB',
                      l2size='256kB')
    pe.dtu.l1cache.hit_latency = 1
    pe.dtu.cpu_to_cache_latency = int(os.environ.get('M3_CACHE_LATENCY'))
    pes.append(pe)

# create the memory PE
pe = createMemPE(root=root,
                 options=options,
                 no=mem_pe,
                 size='1024MB',
                 content=fsimg)
pes.append(pe)

runSimulation(options, pes)
