#!/bin/zsh

get_lines() {
    cloc --json --quiet $@ | python -c "
import json, sys
res = json.load(sys.stdin)
print(res['SUM']['code'])
"
}

kernel=$(get_lines m3/src/apps/kernel)
kernel_pes=$(get_lines m3/src/apps/kernel/pes m3/src/apps/kernel/arch/gem5/VPE.cc)
kernel_rem=$(get_lines m3/src/apps/kernel/arch/gem5/{AddrSpace.cc,DTU.cc,DTURegs.h,DTUState.cc})
kernel_mem=$(get_lines m3/src/apps/kernel/mem)
kernel_caps=$(get_lines m3/src/apps/kernel/cap)
kernel_sysc=$(get_lines m3/src/apps/kernel/SyscallHandler.*)
kernel_arch=$(get_lines m3/src/apps/kernel/arch)
kernel_bare=$(get_lines m3/src/apps/kernel/arch/baremetal)
kernel_gem5=$(get_lines m3/src/apps/kernel/arch/gem5)
kernel_total=$((($kernel - $kernel_arch) + $kernel_bare + $kernel_gem5))
echo kernel: $kernel_total
echo kernel PEs: $kernel_pes
echo kernel rem: $kernel_rem
echo kernel mem: $kernel_mem
echo kernel caps: $kernel_caps
echo kernel sysc: $kernel_sysc
echo ------------

lbase=$(get_lines m3/src/libs/base)
lbase_arch=$(get_lines m3/src/libs/base/arch)
lbase_gem5=$(get_lines m3/src/libs/base/arch/{gem5,baremetal})
lbase_x86=$(get_lines m3/src/libs/base/arch/{gem5-x86_64,x86_64})
lbase_arm=$(get_lines m3/src/libs/base/arch/{gem5-arm,arm})
ibase=$(get_lines m3/src/include/base)
ibase_arch=$(get_lines m3/src/include/base/arch)
ibase_unused=$(get_lines m3/src/include/base/{tracing,ELF.h})
ibase_gem5=$(get_lines m3/src/libs/base/arch/{gem5,baremetal})
ibase_x86=$(get_lines m3/src/libs/base/arch/x86_64)
ibase_arm=$(get_lines m3/src/libs/base/arch/arm)
base_x86=$(($lbase_x86 + $ibase_x86))
base_arm=$(($lbase_arm + $ibase_arm))
base_total=$((($lbase - $lbase_arch) + ($ibase - $ibase_arch - $ibase_unused) + \
              $lbase_gem5 + $ibase_gem5 + $base_x86 + $base_arm))
echo base x86: $base_x86
echo base arm: $base_arm
echo base total: $base_total
echo ------------

lheap=$(get_lines m3/src/libs/heap)
iheap=$(get_lines m3/src/include/heap)
heap_total=$((lheap + $iheap))
echo heap: $heap_total
echo ------------

lthread=$(get_lines m3/src/libs/thread)
lthread_x86=$(get_lines m3/src/libs/thread/isa/x86_64)
lthread_arm=$(get_lines m3/src/libs/thread/isa/arm)
ithread=$(get_lines m3/src/include/thread)
ithread_x86=$(get_lines m3/src/include/thread/isa/x86_64)
ithread_arm=$(get_lines m3/src/include/thread/isa/arm)
thread_x86=$(($lthread_x86 + $ithread_x86))
thread_arm=$(($lthread_arm + $ithread_arm))
thread_total=$(($lthread + $ithread + $thread_x86 + $thread_arm))
echo thread total: $thread_total
echo thread x86: $thread_x86
echo thread arm: $thread_arm
echo ------------

support_x86=$(get_lines m3/src/libs/support/gem5-x86_64)
support_arm=$(get_lines m3/src/libs/support/gem5-arm)
csupport=$(get_lines m3/src/libs/c/{stdlib,string,dirent})
csupport_x86=$(get_lines m3/src/libs/c/arch/gem5-x86_64)
csupport_arm=$(get_lines m3/src/libs/c/arch/gem5-arm)
support_x86=$((support_x86 + $csupport_x86))
support_arm=$((support_arm + $csupport_arm))
support_total=$(($csupport + $support_x86 + $support_arm))
echo support total: $support_total
echo support x86: $support_x86
echo support arm: $support_arm
echo ------------

echo kernel-total: $(($kernel_total + base_total + $heap_total + $thread_total + $support_total))
echo libs-total: $(($base_total + $heap_total + $thread_total + $support_total))
echo libs-x86: $(($base_x86 + $thread_x86 + $support_x86))
echo libs-arm: $(($base_arm + $thread_arm + $support_arm))
echo ------------

cuhelper=$(get_lines m3/src/apps/rctmux/Print.*)
cuhelper_rctmux=$(get_lines m3/src/apps/rctmux/RCTMux.* m3/src/apps/rctmux/arch/gem5/RCTMux.cc)
cuhelper_vma=$(get_lines m3/src/apps/rctmux/arch/gem5-x86_64/VMA.*)
cuhelper_x86=$(get_lines m3/src/apps/rctmux/arch/gem5-x86_64/{Entry.S,Exceptions.*,RCTMux.*})
cuhelper_arm=$(get_lines m3/src/apps/rctmux/arch/gem5-arm/{Entry.S,RCTMux.*})

cuhelper_total=$(($cuhelper + $cuhelper_rctmux + $cuhelper_vma + $cuhelper_x86 + $cuhelper_arm))

echo CU-specific helper total: $cuhelper_total
echo RCTMux: $cuhelper_rctmux
echo VMA: $cuhelper_vma
echo x86: $cuhelper_x86
echo arm: $cuhelper_arm
echo ------------

libm3=$(get_lines m3/src/include/m3 m3/src/libs/m3)
libm3_arch=$(get_lines m3/src/libs/m3/arch)
libm3_gem5=$(get_lines m3/src/libs/m3/arch/{gem5,baremetal})
libm3_total=$((($libm3 - $libm3_arch) + $libm3_gem5))

echo libm3: $libm3_total
echo ------------

m3fs=$(get_lines m3/src/apps/m3fs)
pager=$(get_lines m3/src/apps/pager)
pipe=$(get_lines m3/src/apps/pipeserv)

echo m3fs: $m3fs
echo pager: $pager
echo pipe: $pipe
