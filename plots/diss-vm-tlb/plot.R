library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.7
namescale <- 1.7

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(3)

# convert back to time (cycles / 3)
times  <- read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000 * 3)
stddev <- scan(args[3]) / (1000 * 3)

pdf(as.character(args[1]), width=3.5, height=6)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(7,6,4,1))

barplot(as.matrix(times), beside=F, ylim=c(0,1.021), axes=F,
    space=rep(0.2, 3), names.arg=rep("", 3))
abline(h=c(seq(0,1.0,0.2)), col="gray80")

plot <- barplot(as.matrix(times), beside=F, add=T,
    ylim=c(0,1.021), space=rep(0.2, 3), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("M³-B","M³-C","M³-C*"), sub="TLB miss")
axis(2, at = seq(0, 1, .2), las = 2)
title(ylab = "Time (µs)", mgp=c(4, 1, 0))
error.bar(plot, colSums(times), stddev)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("VMA", "IRQ", "Xfer"), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,0), cex=1.6, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
