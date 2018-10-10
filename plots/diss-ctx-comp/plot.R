library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.3

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(1)

ratios <- scan(as.character(args[2]))

print(ratios)

pdf(as.character(args[1]), width=10, height=2.3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(4,8,1,2))

barplot(ratios, beside=F,
    xlim=c(0.99,1), xlab="Runtime (relative)", axes=T, xpd=F,
    col=colors, horiz=T,
    cex.names=namescale, las=1, mgp=c(3, 1, 0),
    space=rep(0.3, 4),
    names.arg=c("1ms","2ms","4ms","8ms"))
title(ylab = "Time slice", mgp=c(4, 1, 0))

dev.off()
embed_fonts(as.character(args[1]))
