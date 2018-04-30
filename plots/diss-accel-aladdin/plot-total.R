library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.8
namescale <- 1.8

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(6)

# convert back to time (cycles / 3)
tstencil    <- scan(args[2]) / (1000000 * 3)
tmd         <- scan(args[3]) / (1000000 * 3)
tfft        <- scan(args[4]) / (1000000 * 3)
tspmv       <- scan(args[5]) / (1000000 * 3)

pdf(as.character(args[1]), width=4, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.86,1,1,1), heights=c(1,1))

par(mar=c(9.5,5.5,4,0.5))

plot <- barplot(tstencil, beside=F,
    ylim=c(0,1.2), space=c(0.3, 0.2), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
    sub="Stencil")
axis(2, at = seq(0, 1.2, 0.3), las = 2)
title(ylab = "Time (ms)", mgp=c(3.6, 1, 0))

par(mar=c(9.5,0,4,0.5))

plot <- barplot(tmd, beside=F,
    ylim=c(0,1.2), space=c(0.3, 0.2), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
    sub="MD")

par(mar=c(9.5,0,4,0.5))

plot <- barplot(tfft, beside=F,
    ylim=c(0,1.2), space=c(0.3, 0.2), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
    sub="FFT")

par(mar=c(9.5,0,4,0.5))

plot <- barplot(tspmv, beside=F,
    ylim=c(0,1.2), space=c(0.3, 0.2), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
    sub="SPMV")

dev.off()
embed_fonts(as.character(args[1]))
