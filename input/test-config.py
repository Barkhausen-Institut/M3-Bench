import os, sys

sys.path.append(os.path.realpath('hw/gem5/configs'))
sys.path.append(os.path.realpath('hw/gem5/configs/example'))
from dtu_fs import *

options = getOptions()
root = createRoot(options)

cmd_list = options.cmd.split(",")

num_mem = 1
num_sto = 1
num_nic = 2
num_pes = int(os.environ.get('M3_GEM5_PES'))
fsimg = os.environ.get('M3_GEM5_FS')
fsimgnum = os.environ.get('M3_GEM5_FSNUM', '1')
num_copy = int(os.environ.get('M3_ACCEL_COUNT', '0'))
num_indir = int(os.environ.get('M3_ACCEL_COUNT', '0'))
petype = os.environ.get('M3_PETYPE')
isa = os.environ.get('M3_ISA')

# disk image
hard_disk0 = os.environ.get('M3_GEM5_IDE_DRIVE')
if not os.path.isfile(hard_disk0):
    num_sto = 0

if petype == 'a' or isa == 'arm':
    l1size = None
    l2size = None
    spmsize = '32MB'
else:
    l1size = '32kB'
    l2size = '256kB'
    spmsize = None

mem_pe = num_pes + num_copy + num_indir + num_sto + num_nic

pes = []

# create the core PEs
for i in range(0, num_pes):
    pe = createCorePE(noc=root.noc,
                      options=options,
                      no=i,
                      cmdline=cmd_list[i],
                      memPE=mem_pe,
                      l1size=l1size,
                      l2size=l2size,
                      spmsize=spmsize,
                      dtupos=0)
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pes.append(pe)

# create the accelerator PEs
options.cpu_clock = '1GHz'

for i in range(0, num_copy):
    pe = createAccelPE(noc=root.noc,
                       options=options,
                       no=num_pes + i,
                       accel='copy',
                       memPE=mem_pe,
                       spmsize='2MB')
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pe.accel.buf_size = '2kB'
    pes.append(pe)

for i in range(0, num_indir):
    pe = createAccelPE(noc=root.noc,
                       options=options,
                       no=num_pes + num_copy + i,
                       accel='indir',
                       memPE=mem_pe,
                       spmsize='2MB')
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pes.append(pe)

# create the persistent storage PEs
for i in range(0, num_sto):
    pe = createStoragePE(noc=root.noc,
                         options=options,
                         no=num_pes + num_copy + num_indir + i,
                         memPE=mem_pe,
                         img0=hard_disk0)
    pes.append(pe)

# create ether PEs
ether0 = createEtherPE(noc=root.noc,
                       options=options,
                       no=num_pes + num_copy + num_indir + num_sto + 0,
                       memPE=mem_pe)
pes.append(ether0)

ether1 = createEtherPE(noc=root.noc,
                       options=options,
                       no=num_pes + num_copy + num_indir + num_sto + 1,
                       memPE=mem_pe)
pes.append(ether1)

linkEtherPEs(ether0, ether1)

# create the memory PEs
for i in range(0, num_mem):
    pe = createMemPE(noc=root.noc,
                     options=options,
                     no=mem_pe + i,
                     size='3072MB',
                     image=fsimg if i == 0 else None,
                     imageNum=int(fsimgnum))
    pe.dtu.max_noc_packet_size = '2kB'
    pe.dtu.buf_size = '2kB'
    pes.append(pe)

runSimulation(root, options, pes)
