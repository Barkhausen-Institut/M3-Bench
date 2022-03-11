import os, sys

sys.path.append(os.path.realpath('platform/gem5/configs'))
sys.path.append(os.path.realpath('platform/gem5/configs/example'))
from tcu_fs import *

options = getOptions()
root = createRoot(options)

cmd_list = options.cmd.split(",")

num_eps = 64 if os.environ.get('M3_TARGET') == 'hw' else 192
num_mem = 1
num_sto = 1
num_nic = 2
num_kecacc = 1
num_tiles = int(os.environ.get('M3_GEM5_TILES'))
fsimg = os.environ.get('M3_GEM5_FS')
fsimgnum = os.environ.get('M3_GEM5_FSNUM', '1')
num_copy = int(os.environ.get('M3_ACCEL_COUNT', '0'))
num_indir = int(os.environ.get('M3_ACCEL_COUNT', '0'))
tiletype = os.environ.get('M3_TILETYPE')
isa = os.environ.get('M3_ISA')

# disk image
hard_disk0 = os.environ.get('M3_GEM5_IDE_DRIVE')
if not os.path.isfile(hard_disk0):
    num_sto = 0

if tiletype == 'a':
    l1size = None
    l2size = None
    spmsize = '32MB'
else:
    l1size = '32kB'
    l2size = '256kB'
    spmsize = None

mem_tile = num_tiles + num_copy + num_indir + num_sto + num_nic + num_kecacc

tiles = []

# create the core tiles
for i in range(0, num_tiles):
    tile = createCoreTile(noc=root.noc,
                          options=options,
                          no=i,
                          cmdline=cmd_list[i],
                          memTile=mem_tile,
                          l1size=l1size,
                          l2size=l2size,
                          spmsize=spmsize,
                          tcupos=0,
                          epCount=num_eps)
    tile.tcu.max_noc_packet_size = '2kB'
    tile.tcu.buf_size = '2kB'
    tiles.append(tile)

# create the accelerator tiles
options.cpu_clock = '1GHz'

for i in range(0, num_copy):
    tile = createAccelTile(noc=root.noc,
                           options=options,
                           no=num_tiles + i,
                           accel='copy',
                           memTile=mem_tile,
                           spmsize='4MB',
                           epCount=num_eps)
    tile.tcu.max_noc_packet_size = '2kB'
    tile.tcu.buf_size = '2kB'
    tile.accel.buf_size = '2kB'
    tiles.append(tile)

for i in range(0, num_indir):
    tile = createAccelTile(noc=root.noc,
                           options=options,
                           no=num_tiles + num_copy + i,
                           accel='indir',
                           memTile=mem_tile,
                           spmsize='4MB',
                           epCount=num_eps)
    tile.tcu.max_noc_packet_size = '2kB'
    tile.tcu.buf_size = '2kB'
    tiles.append(tile)

# create the persistent storage tiles
for i in range(0, num_sto):
    tile = createStorageTile(noc=root.noc,
                             options=options,
                             no=num_tiles + num_copy + num_indir + i,
                             memTile=mem_tile,
                             img0=hard_disk0,
                             epCount=num_eps)
    tiles.append(tile)

for i in range(0, num_kecacc):
    tile = createKecAccTile(noc=root.noc,
                            options=options,
                            no=num_tiles + num_copy + num_indir + num_sto + i,
                            cmdline=cmd_list[1],  # FIXME
                            memTile=mem_tile,
                            spmsize='32MB',
                            epCount=num_eps)
    tiles.append(tile)

# create ether tiles
ether0 = createEtherTile(noc=root.noc,
                         options=options,
                         no=num_tiles + num_copy + num_indir + num_sto + num_kecacc + 0,
                         memTile=mem_tile,
                         epCount=num_eps)
tiles.append(ether0)

ether1 = createEtherTile(noc=root.noc,
                         options=options,
                         no=num_tiles + num_copy + num_indir + num_sto + num_kecacc + 1,
                         memTile=mem_tile,
                         epCount=num_eps)
tiles.append(ether1)

linkEthertiles(ether0, ether1)

# create the memory tiles
for i in range(0, num_mem):
    tile = createMemTile(noc=root.noc,
                         options=options,
                         no=mem_tile + i,
                         size='3072MB',
                         image=fsimg if i == 0 else None,
                         imageNum=int(fsimgnum),
                         epCount=num_eps)
    tile.tcu.max_noc_packet_size = '2kB'
    tile.tcu.buf_size = '2kB'
    tiles.append(tile)

runSimulation(root, options, tiles)
