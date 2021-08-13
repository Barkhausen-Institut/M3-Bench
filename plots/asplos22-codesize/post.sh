#!/bin/sh

COUNT=$HOME/Applications/cargo-count/target/release/cargo-count

cd m3

total_lines() {
    $COUNT count --unsafe-statistics $@ | grep "Totals:" | awk '{ print($6) }'
}
unsafe_lines() {
    $COUNT count --unsafe-statistics $@ | grep "Totals:" | awk '{ print($7) }'
}

kernalltotal=$(total_lines src/kernel src/libs/rust/{base,isr,paging,thread})
kernexltotal=$(total_lines src/kernel/src/arch/host \
                           src/libs/rust/base/src/arch/{arm,host,x86_64} \
                           src/libs/rust/isr/src/{arm,x86_64} \
                           src/libs/rust/paging/src/{arm,x86_64})
kernallunsaf=$(unsafe_lines src/kernel src/libs/rust/{base,isr,paging,thread})
kernexlunsaf=$(unsafe_lines src/kernel/src/arch/host \
                            src/libs/rust/base/src/arch/{arm,host,x86_64} \
                            src/libs/rust/isr/src/{arm,x86_64} \
                            src/libs/rust/paging/src/{arm,x86_64})

pemuxalltotal=$(total_lines src/pemux)
pemuxexctotal=$(total_lines src/pemux/src/arch/{arm,x86_64})
pemuxallunsaf=$(unsafe_lines src/pemux)
pemuxexcunsaf=$(unsafe_lines src/pemux/src/arch/{arm,x86_64})

sysalltotal=$(total_lines src/server/{m3fs,net,pager,root} src/libs/rust/{m3,resmng})
sysexctotal=$(total_lines src/libs/m3/arch/host)
sysallunsaf=$(unsafe_lines src/server/{m3fs,net,pager,root} src/libs/rust/{m3,resmng} src/libs/axieth)
sysexcunsaf=$(unsafe_lines src/libs/m3/arch/host src/libs/axieth/{axi_ethernet_driver.cc,env.cc,xaxieth*})

echo Component Total Unsafe
echo kernel $(($kernalltotal - $kernexltotal)) $(($kernallunsaf - $kernexlunsaf))
echo pemux $(($pemuxalltotal - $pemuxexctotal)) $(($pemuxallunsaf - $pemuxexcunsaf))
echo services $(($sysalltotal - $sysexctotal)) $(($sysallunsaf - $sysexcunsaf))
