library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.4
namescale <- 1.4

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

# convert back to time (cycles / 3)
cmptimes <- read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000000 * 3)
stddev <- scan(args[3]) / (1000000 * 3)

pdf(as.character(args[1]), width=6, height=3.2)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(5,5,1,1))

barplot(as.matrix(cmptimes), beside=F, ylim=c(0,20), axes=F,
    space=c(0.2, 0.2, 0.2, 0.4, 0.2, 0.2), names.arg=rep("", 6))
abline(h=c(seq(0,20,5)), col="gray80")

plot <- barplot(as.matrix(cmptimes), beside=F, add=T,
    ylim=c(0,20), space=c(0.2, 0.2, 0.2, 0.4, 0.2, 0.2), ylab="", axes=F,
    col=colors, cex.names=namescale, las=2, mgp=c(3, 1, 0),
    names.arg=c("Linux", "Lx-rd", "Lx-wr", "M³", "M³-rd", "M³-wr"))
axis(2, at = seq(0, 20, 5), las = 2)
title(ylab = "Time (ms)", mgp=c(3, 1, 0))
error.bar(plot, colSums(cmptimes), stddev)

dev.off()
embed_fonts(as.character(args[1]))
