library(extrafont)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.25
namescale <- 1.25
colors <- brewer.pal(n = 4, name = "Pastel1")

ratios <- read.table(as.character(args[2]), header=TRUE, sep=" ")

print(ratios)

pdf(as.character(args[1]), width=9, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(3,4,2,0))

barplot(as.matrix(t(ratios)), beside=T, axes=F,
    ylim=c(0,3.5), space=rep(c(0.4, 0.1, 0.1, 0.1), 7), names.arg=rep("", 7))
abline(h=c(seq(0,3.5,1)), col="gray80")

barplot(as.matrix(t(ratios)), beside=T, axes=F, add=T,
    ylim=c(0,3.5), space=rep(c(0.4, 0.1, 0.1, 0.1), 7), ylab="",
    col=colors,
    cex.names=namescale,
    names=c("tar", "untar", "shasum", "sort", "find", "SQLite", "LevelDB"))
axis(2, at = seq(0, 3.5, 1), las = 2)
title(ylab = "Relative runtime", mgp=c(2.5, 1, 0))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("M³ (3 PEs)", "M³ (2 PEs)", "M³ (1 PE)", "Linux (1 core)"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
