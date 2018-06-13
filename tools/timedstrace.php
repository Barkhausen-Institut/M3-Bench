#!/usr/bin/php
<?php
// syscall numbers for x86_64
$names = array(
    2 => "open",
    3 => "close",
    0 => "read",
    1 => "write",
    8 => "lseek",
    77 => "ftruncate",
    74 => "fsync",
    17 => "pread",
    18 => "pwrite",
    82 => "rename",
    87 => "unlink",
    84 => "rmdir",
    83 => "mkdir",
    4 => "stat",
    6 => "lstat",
    5 => "fstat",
    217 => "getdents64",
    262 => "newfstatat",
    40 => "sendfile",
    23 => "select",
    288 => "accept4",
    45 => "recvfrom",
    20 => "writev",
    // 96 => "gettimeofday",
);
$numbers = array_flip($names);

if($argc < 4)
    exit("Usage: {$argv[0]} (trace|waittime|total|human) <strace> <timings> [--no-ioctl]\n");

$mode = $argv[1];
$strace = file($argv[2]);
$times = file($argv[3]);
$seen_ioctl = false;
if(isset($argv[4]) && $argv[4] == '--no-ioctl')
    $seen_ioctl = true;

$last = 0;
$start = 0;
$timestamp = 0;
$i = 0;
$j = 0;
$waittime = 0;
for(; isset($strace[$j]) && isset($times[$i]); $i++, $j++) {
    preg_match('/^\s*\[\s*\d+\]\s+(\d+)\s+(\d+)\s+(\d+)/', $times[$i], $ti);
    preg_match('/^(.+?)\(([^,]*)/', $strace[$j], $st);

    // ignore everything up to the first ioctl to ignore the dynamic linking stuff
    if(!$seen_ioctl && $st[1] != 'ioctl') {
        if(isset($numbers[$st[1]]) && @$names[$ti[1]] != $st[1]) {
            @file_put_contents('php://stderr',
                "Warning in line $i: syscalls do not match: " . $ti[1] . " vs. " . $st[1] . "\n");
            // use the same entry of $strace again
            $j--;
        }
        continue;
    }
    $seen_ioctl = true;

    if($mode == 'total' && $start == 0)
        $start = $ti[3];

    $last = $ti[3];

    // ignore writes to stdout/stderr
    if($st[1] == 'write' && ($st[2] == '1' || $st[2] == '2'))
        continue;

    if(isset($numbers[$st[1]])) {
        if(@$names[$ti[1]] != $st[1]) {
            @file_put_contents('php://stderr',
                "Warning in line $j: syscalls do not match: " . $ti[1] . " vs. " . $st[1] . "\n");
            $i--;
            continue;
        }

        if($mode == 'trace') {
            // ignore waits of less than 1000 cycles.
            if($timestamp > 0 && ($ti[2] - $timestamp) > 1000)
                echo "_waituntil(" . ($ti[2] - $timestamp) . ") = 0\n";
        }
        else if($mode == 'waittime' && $timestamp > 0)
            $waittime += $ti[2] - $timestamp;
        $timestamp = $ti[3];

        if($mode == 'human')
            printf("%12s : %u\n", $names[$ti[1]], $ti[3] - $ti[2]);
    }
    else {
        file_put_contents('php://stderr', "Warning in line $i: ignoring system call " . $st[1] . "\n");
        if($timestamp == 0)
            @$timestamp = $ti[2];
    }

    if($mode == 'trace')
        echo $strace[$j];
}

if($mode == 'trace') {
    if($timestamp > 0 && ($last - $timestamp) > 1000)
        echo "_waituntil(" . ($last - $timestamp) . ") = 0\n";
}
else if($mode == 'waittime') {
    if($timestamp > 0)
        $waittime += $last - $timestamp;
    echo $waittime . "\n";
}
else if($mode == 'total')
    echo ($last - $start) . "\n";
?>