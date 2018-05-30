library(extrafont)
source("tools/helper.R")

scaling <- 1.3
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(4.5,4.5,2,0))

vals <- read.table(as.character(args[2]), header=TRUE, sep=" ")

barplot(
    as.matrix(vals),
    ylim=c(0,3.5),
    xlab="Message size (Bytes)",
    ylab="Avg Power (mW)",
    col=gray.colors(2),
    names=c("8","64","128","256","512"),
    beside=TRUE
)

legend("top", rownames(vals),
    xpd=TRUE, horiz=TRUE, bty="n", inset=c(0,-0.13), cex=scaling, fill=gray.colors(2))

dev.off()
embed_fonts(as.character(args[1]))
