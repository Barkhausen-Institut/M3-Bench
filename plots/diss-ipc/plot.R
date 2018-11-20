library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.4
colors <- brewer.pal(n = 3, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(2.5,4.5,1,0))

vals = scan(args[2]) / 1000
dev = scan(args[3]) / 1000
zeros = rep(c(NA), 3)

barplot(zeros, ylim=c(0, 10), axes=F,
    space=rep(0.1, 3), names.arg=rep("", 3))
abline(h=c(seq(0,10,2)), col="gray80", lwd=2)

plot = barplot(
    vals,
    add=T,
    names=c("NOVA (lo)", "NOVA (re)", "M³ (re)"),
    space=rep(0.1, 3),
    ylab = "Duration (K Cycles)",
    ylim = c(0, 10),
    col=colors
)
error.bar(plot, vals, dev)

dev.off()
embed_fonts(as.character(args[1]))
