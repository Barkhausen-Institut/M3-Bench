// This file has been automatically generated by strace2c.
// Do not edit it!

#include "common/op_types.h"

trace_op_t trace_ops[] = {
    /* #1 = 0x1 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 178380 } },
    /* #2 = 0x2 */ { .opcode = OPEN_OP, .args.open = { 3, "/untardata/tar-16m.tar", O_RDONLY, 0 } },
    /* #3 = 0x3 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 14387 } },
    /* #4 = 0x4 */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 1 } },
    /* #5 = 0x5 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 23393 } },
    /* #6 = 0x6 */ { .opcode = UNLINK_OP, .args.unlink = { -1, "/tmp/1024.bin" } },
    /* #7 = 0x7 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 1226 } },
    /* #8 = 0x8 */ { .opcode = OPEN_OP, .args.open = { 4, "/tmp/1024.bin", O_WRONLY|O_CREAT|O_EXCL, 0100664 } },
    /* #9 = 0x9 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 3783 } },
    /* #10 = 0xa */ { .opcode = SENDFILE_OP, .args.sendfile = { 1048576, 4, 3, NULL, 1048576 } },
    /* #11 = 0xb */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 14444 } },
    /* #12 = 0xc */ { .opcode = CLOSE_OP, .args.close = { 0, 4 } },
    /* #13 = 0xd */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 86311 } },
    /* #14 = 0xe */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 1 } },
    /* #15 = 0xf */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 23811 } },
    /* #16 = 0x10 */ { .opcode = UNLINK_OP, .args.unlink = { -1, "/tmp/128.bin" } },
    /* #17 = 0x11 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 3320 } },
    /* #18 = 0x12 */ { .opcode = OPEN_OP, .args.open = { 4, "/tmp/128.bin", O_WRONLY|O_CREAT|O_EXCL, 0100664 } },
    /* #19 = 0x13 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 1867 } },
    /* #20 = 0x14 */ { .opcode = SENDFILE_OP, .args.sendfile = { 131072, 4, 3, NULL, 131072 } },
    /* #21 = 0x15 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 3017 } },
    /* #22 = 0x16 */ { .opcode = CLOSE_OP, .args.close = { 0, 4 } },
    /* #23 = 0x17 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 56616 } },
    /* #24 = 0x18 */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 1 } },
    /* #25 = 0x19 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 19349 } },
    /* #26 = 0x1a */ { .opcode = UNLINK_OP, .args.unlink = { -1, "/tmp/2048.bin" } },
    /* #27 = 0x1b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 2543 } },
    /* #28 = 0x1c */ { .opcode = OPEN_OP, .args.open = { 4, "/tmp/2048.bin", O_WRONLY|O_CREAT|O_EXCL, 0100664 } },
    /* #29 = 0x1d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 1009 } },
    /* #30 = 0x1e */ { .opcode = SENDFILE_OP, .args.sendfile = { 2097152, 4, 3, NULL, 2097152 } },
    /* #31 = 0x1f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 6518 } },
    /* #32 = 0x20 */ { .opcode = CLOSE_OP, .args.close = { 0, 4 } },
    /* #33 = 0x21 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 73919 } },
    /* #34 = 0x22 */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 1 } },
    /* #35 = 0x23 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 24362 } },
    /* #36 = 0x24 */ { .opcode = UNLINK_OP, .args.unlink = { -1, "/tmp/256.bin" } },
    /* #37 = 0x25 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 3092 } },
    /* #38 = 0x26 */ { .opcode = OPEN_OP, .args.open = { 4, "/tmp/256.bin", O_WRONLY|O_CREAT|O_EXCL, 0100664 } },
    /* #39 = 0x27 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 1947 } },
    /* #40 = 0x28 */ { .opcode = SENDFILE_OP, .args.sendfile = { 262144, 4, 3, NULL, 262144 } },
    /* #41 = 0x29 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 5875 } },
    /* #42 = 0x2a */ { .opcode = CLOSE_OP, .args.close = { 0, 4 } },
    /* #43 = 0x2b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 65718 } },
    /* #44 = 0x2c */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 1 } },
    /* #45 = 0x2d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 21864 } },
    /* #46 = 0x2e */ { .opcode = UNLINK_OP, .args.unlink = { -1, "/tmp/4096.bin" } },
    /* #47 = 0x2f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 3453 } },
    /* #48 = 0x30 */ { .opcode = OPEN_OP, .args.open = { 4, "/tmp/4096.bin", O_WRONLY|O_CREAT|O_EXCL, 0100664 } },
    /* #49 = 0x31 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 1313 } },
    /* #50 = 0x32 */ { .opcode = SENDFILE_OP, .args.sendfile = { 4194304, 4, 3, NULL, 4194304 } },
    /* #51 = 0x33 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 7629 } },
    /* #52 = 0x34 */ { .opcode = CLOSE_OP, .args.close = { 0, 4 } },
    /* #53 = 0x35 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 69121 } },
    /* #54 = 0x36 */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 1 } },
    /* #55 = 0x37 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 23695 } },
    /* #56 = 0x38 */ { .opcode = UNLINK_OP, .args.unlink = { -1, "/tmp/512.bin" } },
    /* #57 = 0x39 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 3096 } },
    /* #58 = 0x3a */ { .opcode = OPEN_OP, .args.open = { 4, "/tmp/512.bin", O_WRONLY|O_CREAT|O_EXCL, 0100664 } },
    /* #59 = 0x3b */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 1927 } },
    /* #60 = 0x3c */ { .opcode = SENDFILE_OP, .args.sendfile = { 524288, 4, 3, NULL, 524288 } },
    /* #61 = 0x3d */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 4681 } },
    /* #62 = 0x3e */ { .opcode = CLOSE_OP, .args.close = { 0, 4 } },
    /* #63 = 0x3f */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 65190 } },
    /* #64 = 0x40 */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 1 } },
    /* #65 = 0x41 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 20723 } },
    /* #66 = 0x42 */ { .opcode = UNLINK_OP, .args.unlink = { -1, "/tmp/8192.bin" } },
    /* #67 = 0x43 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 3118 } },
    /* #68 = 0x44 */ { .opcode = OPEN_OP, .args.open = { 4, "/tmp/8192.bin", O_WRONLY|O_CREAT|O_EXCL, 0100664 } },
    /* #69 = 0x45 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 1268 } },
    /* #70 = 0x46 */ { .opcode = SENDFILE_OP, .args.sendfile = { 8388608, 4, 3, NULL, 8388608 } },
    /* #71 = 0x47 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 7737 } },
    /* #72 = 0x48 */ { .opcode = CLOSE_OP, .args.close = { 0, 4 } },
    /* #73 = 0x49 */ { .opcode = WAITUNTIL_OP, .args.waituntil = { 0, 72734 } },
    /* #74 = 0x4a */ { .opcode = READ_OP, .args.read = { 512, 3, 512, 21 } },
    /* #75 = 0x4b */ { .opcode = READ_OP, .args.read = { 0, 3, 512, 1 } },
    /* #76 = 0x4c */ { .opcode = CLOSE_OP, .args.close = { 0, 3 } },
    { .opcode = INVALID_OP } 
};
