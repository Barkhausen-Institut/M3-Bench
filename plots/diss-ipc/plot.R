library(extrafont)
source("tools/helper.R")

scaling <- 1.3
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(2.5,4.5,1,0))

vals = scan(args[2]) / 1000
dev = scan(args[3]) / 1000

plot = barplot(
    vals,
    names=c("NOVA (loc)", "NOVA (rem)", "M³ (rem)"),
    ylab = "Duration (K Cycles)",
    ylim = c(0, 10),
    col=gray.colors(3)
)
error.bar(plot, vals, dev)

dev.off()
embed_fonts(as.character(args[1]))
