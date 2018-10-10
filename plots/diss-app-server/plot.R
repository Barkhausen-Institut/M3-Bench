library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.25
namescale <- 1.25

times <- read.table(as.character(args[2]), header=T, sep=" ") / 1000

print(times)

pdf(as.character(args[1]), width=5, height=3, useDingbats=FALSE)
par(mar=c(4.1,4.3,2.5,1))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

plot(c(1,2,4,8,16,32), times$s1, ylim=c(0,256), type="o", pch=0, axes=FALSE, xlab="", ylab="")
abline(h=c(seq(0,256,64)), col="gray80")
par(new=T)

plot(c(1,2,4,8,16,32), times$s1, ylim=c(0,256), type="o", pch=0, axes=FALSE, xlab="", ylab="")
abline(v=c(seq(0,32,8)), col="gray80")
par(new=T)

plot(c(1,2,4,8,16,32), times$s1, ylim=c(0,256), type="o", pch=0, axes=FALSE, ylab="", xlab="")
lines(c(1,2,4,8,16,32), times$s2, ylim=c(0,256), type="o", pch=1, lty="dashed")
lines(c(1,2,4,8,16,32), times$s4, ylim=c(0,256), type="o", pch=2, lty="dotted")
lines(c(1,2,4,8,16,32), times$s8, ylim=c(0,256), type="o", pch=3, lty="dashed")
title(ylab = "Requests / s (x 1000)", mgp=c(3, 1, 0))
title(xlab = "# of nginx VPEs", mgp=c(2, 1, 0))

axis(side = 1, at = seq(0, 32, 8), line = -0.31)
axis(side = 2, at = seq(0, 256, 64), labels = TRUE, las=1, line = -0.14)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
linetype <- c(1:4)
plotchar <- seq(0, 3, 1)
legend("top", c("1 srv", "2 srv", "4 srv", "8 srv"), horiz=T, bty="n",
    cex=namescale, pch=plotchar, lty=linetype, inset=c(0,0))

dev.off()
embed_fonts(as.character(args[1]))
