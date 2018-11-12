library(extrafont)
library(optimbase)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.3
colors <- brewer.pal(n = 3, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(4.5,4.5,1.5,0))

vals <- read.table(as.character(args[2]), header=TRUE, sep=" ") * 1000

barplot(
    transpose(as.matrix(vals)),
    ylim=c(0,15),
    xlab="Compute time (K cycles)",
    ylab="Avg Power (mW)",
    col=colors,
    # numbers from imdata zwischenbericht M2
    names=c("0.5","1","2","4","10"),
    beside=FALSE
)

legend("top", colnames(vals),,
    xpd=TRUE, horiz=TRUE, bty="n", inset=c(0,-0.1), cex=scaling, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
