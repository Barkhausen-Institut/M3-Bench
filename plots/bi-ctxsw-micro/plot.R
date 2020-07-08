library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.1
colors <- brewer.pal(n = 4, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(2.5,4.5,1,0))

vals = scan(args[2])
dev = scan(args[3])
zeros = rep(c(NA), 4)

barplot(zeros, ylim=c(0, 2000), axes=F,
    space=rep(0.1, 4), names.arg=rep("", 4),
    ylab = "Duration (Cycles)")
abline(h=c(seq(0, 2000, 500)), col="gray80", lwd=2)

plot = barplot(
    vals,
    add=T,
    names=c("IPC cross", "IPC local", "PEXCall", "TCU miss"),
    space=rep(0.1, 4),
    mgp=c(2.5, 0.5, 0),
    ylab = "Duration (Cycles)",
    ylim = c(0, 2000),
    col=colors
)
error.bar(plot, vals, dev)

dev.off()
embed_fonts(as.character(args[1]))
