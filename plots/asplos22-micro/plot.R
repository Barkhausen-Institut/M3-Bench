library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.9
colors <- brewer.pal(n = 4, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=10, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(4.5, 10, 1, 2))

vals = rev(scan(args[2]) / 1000)
dev = rev(scan(args[3]) / 1000)
zeros = rep(c(NA), 4)

barplot(zeros, xlim=c(0, 10), axes=F, space=rep(0.1, 4),
    horiz=T, names.arg=rep("", 4), las=1, xlab="Duration (K Cycles)")
abline(v=c(seq(0, 10, 2)), col="gray80", lwd=2)

plot = barplot(
    vals,
    add=T,
    horiz=T,
    names=rev(c("UCS² Rem", "UCS² Loc", "Lx Syscall", "Lx Yield")),
    space=rep(0.1, 4),
    xlim=c(0, 10),
    mgp=c(8, 1.5, 0),
    las=1,
    col=rev(colors)
)
error.bar(plot, vals, dev, horizontal=T)

dev.off()
embed_fonts(as.character(args[1]))
