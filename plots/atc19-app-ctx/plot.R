library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2.2
namescale <- 2

# colors <- c("#2b8cbe","#a6bddb","#ece7f2")
colors <- gray.colors(4)

ratios <- read.table(as.character(args[2]), header=TRUE, sep=" ")

pdf(as.character(args[1]), width=9, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Linux Biolinum")

par(mar=c(2.5,4,3,0))

barplot(as.matrix(t(ratios)), beside=T, axes=F,
    ylim=c(0,3.5), space=rep(c(0.4, 0.1, 0.1, 0.1), 7), names.arg=rep("", 7))
abline(h=c(seq(0,3.5,1)), col="gray80")

barplot(as.matrix(t(ratios)), beside=T, axes=F, add=T,
    ylim=c(0,3.5), space=rep(c(0.4, 0.1, 0.1, 0.1), 7), ylab="",
    col=colors,
    cex.names=scaling,
    names=c("tar", "untar", "sha", "sort", "find", "SQLi", "LDB"))
axis(2, at = seq(0, 3.5, 1), las = 2)
title(ylab = "Rel. runtime", mgp=c(2.5, 1, 0))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("M3x (3 tiles)", "M3x (2 tiles)", "M3x (1 tile)", "Lx (1 core)"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=namescale, fill=colors, x.intersp=0.3)

dev.off()
embed_fonts(as.character(args[1]))
