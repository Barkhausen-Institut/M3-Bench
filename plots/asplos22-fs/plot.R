library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.8
colors <- brewer.pal(n = 6, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=10, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(4.5, 11.5, 1, 2))

vals = rev(scan(args[2]) / 1000000)
dev = rev(scan(args[3]) / 1000000)
zeros = rep(c(NA), 6)

barplot(zeros, xlim=c(0, 250), axes=F, space=rep(0.1, 6), horiz=T,
    names.arg=rep("", 6), xlab="Throughput (MiB/s)")
abline(v=c(seq(0, 250, 50)), col="gray80", lwd=2)

plot = barplot(
    vals,
    add=T,
    names=rev(c("UCS² Rd-Iso", "UCS² Rd-Sh", "UCS² Wr-Iso", "UCS² Wr-Sh", "Lx Rd", "Lx Wr")),
    space=rep(0.1, 6),
    horiz=T,
    xlim=c(0, 250),
    col=rev(colors),
    las=1,
)
error.bar(plot, vals, dev, horizontal=T)

dev.off()
embed_fonts(as.character(args[1]))
