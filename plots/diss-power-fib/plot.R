library(extrafont)
library(optimbase)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.28
colors <- brewer.pal(n = 3, name = "Pastel1")

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(4.5,4.5,1.5,0))

vals <- read.table(as.character(args[2]), header=TRUE, sep=" ") * 1000
zeros <- matrix(rep(c(NA), 3 * 5), nrow=3, ncol=5)

barplot(as.matrix(zeros), beside=F, ylim=c(0,15), axes=F,
    names.arg=rep("", 5))
abline(h=c(seq(0,15,2)), col="gray80", lwd=2)

barplot(
    transpose(as.matrix(vals)),
    add=T,
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
