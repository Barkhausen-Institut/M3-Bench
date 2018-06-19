// This file has been automatically generated by strace2c.
// Do not edit it!

#include "../common/op_types.h"

trace_op_t trace_ops_sort[] = {
    /* #1 = 0x1 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 91025 } },
    /* #2 = 0x2 */ { .opcode = OPEN_OP, .args.open = { 3, "/unsorted.txt", O_RDONLY, 0 } },
    /* #3 = 0x3 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 22220 } },
    /* #4 = 0x4 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #5 = 0x5 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 95526 } },
    /* #6 = 0x6 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #7 = 0x7 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83849 } },
    /* #8 = 0x8 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #9 = 0x9 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84414 } },
    /* #10 = 0xa */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #11 = 0xb */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84033 } },
    /* #12 = 0xc */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #13 = 0xd */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83640 } },
    /* #14 = 0xe */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #15 = 0xf */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83788 } },
    /* #16 = 0x10 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #17 = 0x11 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 91127 } },
    /* #18 = 0x12 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #19 = 0x13 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 86591 } },
    /* #20 = 0x14 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #21 = 0x15 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 85038 } },
    /* #22 = 0x16 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #23 = 0x17 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84877 } },
    /* #24 = 0x18 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #25 = 0x19 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 93626 } },
    /* #26 = 0x1a */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #27 = 0x1b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 82553 } },
    /* #28 = 0x1c */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #29 = 0x1d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81818 } },
    /* #30 = 0x1e */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #31 = 0x1f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 82988 } },
    /* #32 = 0x20 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #33 = 0x21 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83065 } },
    /* #34 = 0x22 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #35 = 0x23 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 82852 } },
    /* #36 = 0x24 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #37 = 0x25 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81140 } },
    /* #38 = 0x26 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #39 = 0x27 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 80957 } },
    /* #40 = 0x28 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #41 = 0x29 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81667 } },
    /* #42 = 0x2a */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #43 = 0x2b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81304 } },
    /* #44 = 0x2c */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #45 = 0x2d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 106882 } },
    /* #46 = 0x2e */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #47 = 0x2f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 78578 } },
    /* #48 = 0x30 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #49 = 0x31 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 98342 } },
    /* #50 = 0x32 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #51 = 0x33 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 224912 } },
    /* #52 = 0x34 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #53 = 0x35 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 82580 } },
    /* #54 = 0x36 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #55 = 0x37 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83613 } },
    /* #56 = 0x38 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #57 = 0x39 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84923 } },
    /* #58 = 0x3a */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #59 = 0x3b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84519 } },
    /* #60 = 0x3c */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #61 = 0x3d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84177 } },
    /* #62 = 0x3e */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #63 = 0x3f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83033 } },
    /* #64 = 0x40 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #65 = 0x41 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 88239 } },
    /* #66 = 0x42 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #67 = 0x43 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84718 } },
    /* #68 = 0x44 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #69 = 0x45 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83543 } },
    /* #70 = 0x46 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #71 = 0x47 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 88121 } },
    /* #72 = 0x48 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #73 = 0x49 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81443 } },
    /* #74 = 0x4a */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #75 = 0x4b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83247 } },
    /* #76 = 0x4c */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #77 = 0x4d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83903 } },
    /* #78 = 0x4e */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #79 = 0x4f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 82440 } },
    /* #80 = 0x50 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #81 = 0x51 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83983 } },
    /* #82 = 0x52 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #83 = 0x53 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81452 } },
    /* #84 = 0x54 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #85 = 0x55 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 94939 } },
    /* #86 = 0x56 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #87 = 0x57 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 87927 } },
    /* #88 = 0x58 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #89 = 0x59 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 82637 } },
    /* #90 = 0x5a */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #91 = 0x5b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84972 } },
    /* #92 = 0x5c */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #93 = 0x5d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83206 } },
    /* #94 = 0x5e */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #95 = 0x5f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81262 } },
    /* #96 = 0x60 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #97 = 0x61 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 80813 } },
    /* #98 = 0x62 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #99 = 0x63 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 86184 } },
    /* #100 = 0x64 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #101 = 0x65 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 81089 } },
    /* #102 = 0x66 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #103 = 0x67 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 80526 } },
    /* #104 = 0x68 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #105 = 0x69 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 102846 } },
    /* #106 = 0x6a */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #107 = 0x6b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 90613 } },
    /* #108 = 0x6c */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #109 = 0x6d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84197 } },
    /* #110 = 0x6e */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #111 = 0x6f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 85965 } },
    /* #112 = 0x70 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #113 = 0x71 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 85015 } },
    /* #114 = 0x72 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #115 = 0x73 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84417 } },
    /* #116 = 0x74 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #117 = 0x75 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 82902 } },
    /* #118 = 0x76 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #119 = 0x77 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 83433 } },
    /* #120 = 0x78 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #121 = 0x79 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 85080 } },
    /* #122 = 0x7a */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #123 = 0x7b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 86341 } },
    /* #124 = 0x7c */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #125 = 0x7d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 94867 } },
    /* #126 = 0x7e */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #127 = 0x7f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 92214 } },
    /* #128 = 0x80 */ { .opcode = READ_OP, .args.read = { 4096, 3, 4096, 1 } },
    /* #129 = 0x81 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 84354 } },
    /* #130 = 0x82 */ { .opcode = READ_OP, .args.read = { 3692, 3, 4096, 1 } },
    /* #131 = 0x83 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 76025 } },
    /* #132 = 0x84 */ { .opcode = READ_OP, .args.read = { 0, 3, 4096, 1 } },
    /* #133 = 0x85 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 10779 } },
    /* #134 = 0x86 */ { .opcode = CLOSE_OP, .args.close = { 0, 3 } },
    /* #135 = 0x87 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 14979129 } },
    /* #136 = 0x88 */ { .opcode = OPEN_OP, .args.open = { 3, "/tmp/sorted.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666 } },
    /* #137 = 0x89 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 13733 } },
    /* #138 = 0x8a */ { .opcode = CLOSE_OP, .args.close = { 0, 3 } },
    /* #139 = 0x8b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 4534720 } },
    { .opcode = INVALID_OP } 
};
