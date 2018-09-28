library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.25
namescale <- 1.25

# colors <- c("#2b8cbe","#a6bddb","#ece7f2")
colors <- gray.colors(4)

ratios <- read.table(as.character(args[2]), header=TRUE, sep=" ")

print(ratios)

pdf(as.character(args[1]), width=9, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(3,5,2.5,0))

barplot(as.matrix(t(ratios)), beside=T, axes=F, xpd=F,
    ylim=c(0.9,1.1), space=rep(c(0.4, 0.1, 0.1, 0.1), 4), names.arg=rep("", 4))
abline(h=c(seq(0.9,1.1,0.05)), col="gray80")

barplot(as.matrix(t(ratios)), beside=T, axes=F, add=T, xpd=F,
    ylim=c(0.9,1.1), space=rep(c(0.4, 0.1, 0.1, 0.1), 4), ylab="",
    col=colors,
    cex.names=namescale,
    names=c("cat|awk", "cat|wc", "grep|awk", "grep|wc"))
axis(2, at = seq(0.9,1.1,0.05), las = 2)
title(ylab = "Relative runtime", mgp=c(4, 1, 0))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("M³ (5 PEs)", "M³ (3 PEs)", "M³ (2 PEs)", "Linux (2 cores)"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
