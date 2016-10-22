library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.4
namescale <- 1.3

times <- read.table(as.character(args[2]), header=TRUE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=2.6)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(4.5,3,2.8,1))
barplot(as.matrix(times), beside=F, horiz=T,
    xlim=c(0,4.5), space=c(0.3, 0.1), ylab="",
    cex.names=namescale, names.arg=c("Indir","Dir"))
title(xlab = "Time (K cycles)", mgp=c(3, 1, 0))
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Cli>", "Srv>", "Hash", "<Srv", "<Cli"),
    xpd=TRUE, horiz=TRUE, bty="n", inset=c(0,0), cex=namescale, fill=gray.colors(5))

dev.off()
embed_fonts(as.character(args[1]))
