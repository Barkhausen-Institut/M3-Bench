library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- .7
colors <- brewer.pal(n = 6, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(2.5, 4.5, 1, 0))

vals = scan(args[2]) / 1000000
dev = scan(args[3]) / 1000000
zeros = rep(c(NA), 6)

barplot(zeros, ylim=c(0, 8), axes=F, space=rep(0.1, 6),
    names.arg=rep("", 6), ylab="Duration (M Cycles)")
abline(h=c(seq(0, 8, 2)), col="gray80", lwd=2)

plot = barplot(
    vals,
    add=T,
    names=c("M³ RdEx", "M³ RdSh", "M³ WrEx", "M³ WrSh", "Lx Rd", "Lx Wr"),
    space=rep(0.1, 6),
    ylim=c(0, 8),
    col=colors
)
error.bar(plot, vals, dev)

dev.off()
embed_fonts(as.character(args[1]))
