library(extrafont)
library(plotrix)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.8
namescale <- 1.8

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(6)

tstencil    <- scan(args[2])
mstencil    <- scan(args[3])
tmd         <- scan(args[4])
mmd         <- scan(args[5])
tfft        <- scan(args[6])
mfft        <- scan(args[7])
tspmv       <- scan(args[8])
mspmv       <- scan(args[9])

pdf(as.character(args[1]), width=4, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(2.35,1,1,1), heights=c(1,1))

par(mar=c(9.5,7.5,4,0.5))

plot <- barplot(tstencil, beside=F,
    ylim=c(100,1000000), space=c(0.3, 0.2), ylab="", axes=T,
    col=colors, log="y",
    cex.names=namescale, las=1, mgp=c(0, 1, 0),
    sub="Stencil")
title(ylab = "Time (ns)", mgp=c(5.5, 1, 0))
segments(plot - 0.2, mstencil, plot + 0.2, mstencil, lwd=2)

par(mar=c(9.5,0,4,0.5))

plot <- barplot(tmd, beside=F,
    ylim=c(100,1000000), space=c(0.3, 0.2), axes=F,
    col=colors, log="y",
    cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
    sub="MD")
segments(plot - 0.2, mmd, plot + 0.2, mmd, lwd=2)

par(mar=c(9.5,0,4,0.5))

plot <- barplot(tfft, beside=F,
    ylim=c(100,1000000), space=c(0.3, 0.2), axes=F,
    col=colors, log="y",
    cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
    sub="FFT")
segments(plot - 0.2, mfft, plot + 0.2, mfft, lwd=2)

par(mar=c(9.5,0,4,0.5))

plot <- barplot(tspmv, beside=F,
    ylim=c(100,1000000), space=c(0.3, 0.2), axes=F,
    col=colors, log="y",
    cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
    sub="SPMV")
segments(plot - 0.2, mspmv, plot + 0.2, mspmv, lwd=2)

dev.off()
embed_fonts(as.character(args[1]))
