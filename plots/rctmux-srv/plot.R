library(extrafont)
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1

times <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" ")) / 1000000

plottimes <- copy(times)
plottimes[ ,`:=`("Name" = NULL)]

pdf(as.character(args[1]), width=7, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(3,5,3.5,2))
barplot(as.matrix(plottimes), beside=F,
    ylim=c(0,7.5), space=c(0.3, 0.1), ylab="",
    cex.names=namescale, names.arg=c("Direct","Indirect"))
title(ylab = "Time (K cycles)", mgp=c(3, 1, 0))
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Cli>", "Fail", "Wake", "CtxSw", "Fwd", "Serv", "<Cli"),
    xpd=TRUE, horiz=TRUE, bty="n", inset=c(0,0), cex=namescale, fill=gray.colors(7))

dev.off()
embed_fonts(as.character(args[1]))
