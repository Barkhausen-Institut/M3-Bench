library(extrafont)
source("tools/helper.R")

scaling <- 1.3
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(2.5,5,1,0))

vals = scan(args[2]) / 1000
dev = scan(args[3]) / 1000

plot = barplot(
    vals,
    names=c("Linux", "M300", "M310", "M311", "M312"),
    ylab = "Time (K Cycles)",
    ylim = c(0, 200),
    col=gray.colors(5)
)
error.bar(plot, vals, dev)

dev.off()
embed_fonts(as.character(args[1]))
