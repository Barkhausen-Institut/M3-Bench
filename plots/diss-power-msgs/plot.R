library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.28
colors <- brewer.pal(n = 3, name = "Pastel1")[1:2]

args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(4.5,4.5,2,0))

vals <- read.table(as.character(args[2]), header=TRUE, sep=" ")
zeros <- matrix(rep(c(NA), 2 * 5), nrow=2, ncol=5)

barplot(as.matrix(zeros), beside=T, ylim=c(0,3.5), axes=F,
    names.arg=rep("", 5))
abline(h=c(seq(0,3.5,.5)), col="gray80", lwd=2)


barplot(
    as.matrix(vals),
    add=T,
    ylim=c(0,3.5),
    xlab="Message size (Bytes)",
    ylab="Avg Power (mW)",
    col=colors,
    names=c("8","64","128","256","512"),
    beside=TRUE
)

legend("top", rownames(vals),
    xpd=TRUE, horiz=TRUE, bty="n", inset=c(0,-0.15), cex=scaling, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
