library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.2
namescale <- 1.2
colors <- brewer.pal(n = 3, name = "Pastel1")[1:2]

times <- read.table(as.character(args[2]), header=F, sep=" ")
pes   <- read.table(as.character(args[3]), header=F, sep=" ")

print(times)

pdf(as.character(args[1]), width=9, height=3.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(6.5,4.2,2,0))

barplot(t(as.matrix(times[,-1])), beside=T, axes=F, ylim=c(0,112),
    space=rep(c(0.3, 0), 11), names.arg=rep("", 22))
abline(h=c(seq(0, 100, 20)), col="gray80")

plot <- barplot(t(as.matrix(times[,-1])), beside=T, add=T,
    ylim=c(0,112),
    space=rep(c(0.3, 0), 11),
    axes=F,
    col=colors,
    axisnames=F)
text(x = plot, y = t(as.matrix(times[,-1])), label = t(as.matrix(pes[,-1])), pos = 3, cex = namescale, col = "black")
axis(2, at = seq(0, 100, 20), las = 2)
axis(1, at = seq(1.3, 1.3 + 2.3*10, 2.3), labels=times[,1], las=2, lwd.ticks=0, cex.axis=1.5)
title(ylab = "System efficiency (%)", mgp=c(3, 1, 0))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,2,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("16 apps", "32 apps"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-.15), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
