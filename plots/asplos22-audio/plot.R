library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.28
colors <- brewer.pal(n = 3, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(2.5, 4.5, 1, 0))

vals <- read.table(as.character(args[2]), header=FALSE, sep=" ") / 1000000
dev = scan(args[3]) / 1000000
zeros <- matrix(rep(c(NA), 3 * 3), nrow=3, ncol=3)

barplot(as.matrix(zeros), beside=F, ylim=c(0,500), axes=F,
    ylab="Duration (M Cycles)")
abline(h=c(seq(0,500,100)), col="gray80", lwd=2)

plot = barplot(
    t(as.matrix(vals)),
    add=T,
    ylim=c(0,500),
    col=colors,
    names=c("Isolated", "Shared", "ShRel"),
    beside=F
)
error.bar(plot, rowSums(vals), dev)

dev.off()
embed_fonts(as.character(args[1]))

