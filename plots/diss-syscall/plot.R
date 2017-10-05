library(extrafont)
source("tools/helper.R")

scaling <- 1.3
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(2.5,5,1,0))

vals = scan(args[2])
dev = scan(args[3])

plot = barplot(
    vals,
    names=c("Linux", "NOVA", "M3"),
    ylab = "Duration (Cycles)",
    ylim = c(0, 450),
    col=gray.colors(3)
)
error.bar(plot, vals, dev)

dev.off()
embed_fonts(as.character(args[1]))
