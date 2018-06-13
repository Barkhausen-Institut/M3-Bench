library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.25
namescale <- 1.25

times <- read.table(as.character(args[2]), header=T, sep=" ")

print(times)

pdf(as.character(args[1]), width=5, height=3, useDingbats=FALSE)
par(mar=c(4.1,4.3,2.1,1))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

# plot(times, ylim=c(0,100), type="o", pch=0, axes=FALSE, xlab="", ylab="")
# abline(h=c(seq(0,100,20)), col="gray80")
# par(new=T)

plot(times$s1, ylim=c(0,100), type="o", pch=0, axes=FALSE, ylab="", xlab="")
lines(times$s2, ylim=c(0,100), type="o", pch=1, lty="dashed")
lines(times$s4, ylim=c(0,100), type="o", pch=2, lty="dotted")
lines(times$s8, ylim=c(0,100), type="o", pch=3, lty="dashed")
title(ylab = "Parallel efficiency (%)", mgp=c(3, 1, 0))
title(xlab = "# of applications", mgp=c(2, 1, 0))

axis(side = 1, at = 1:6, lab = c("1","2","4","8","16","32"), line = -0.5)
axis(side = 2, at = seq(0, 100, 25), labels = TRUE, las=1)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
linetype <- c(1:4)
plotchar <- seq(0, 2, 1)
legend("top", c("1 srv", "2 srv", "4 srv", "8 srv"), horiz=T, bty="n",
    cex=namescale, pch=plotchar, lty=linetype, inset=c(0,0))

dev.off()
embed_fonts(as.character(args[1]))
