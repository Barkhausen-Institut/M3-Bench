library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.25
namescale <- 1.25

times <- read.table(as.character(args[2]), header=T, sep=" ")

print(as.numeric(times[1,]))

pdf(as.character(args[1]), width=5, height=3, useDingbats=FALSE)
par(mar=c(4.1,4.3,2.1,1))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

# plot(times, ylim=c(0,100), type="o", pch=0, axes=FALSE, xlab="", ylab="")
# abline(h=c(seq(0,100,20)), col="gray80")
# par(new=T)

plot(c(1,2,4,8,16), as.numeric(times[1,]), ylim=c(90,100), type="o", pch=0, lty=1, axes=F, ylab="", xlab="")
lines(c(1,2,4,8,16), as.numeric(times[2,]), ylim=c(90,100), type="o", pch=1, lty=2)
lines(c(1,2,4,8,16), as.numeric(times[3,]), ylim=c(90,100), type="o", pch=2, lty=3)
lines(c(1,2,4,8,16), as.numeric(times[4,]), ylim=c(90,100), type="o", pch=3, lty=4)
title(ylab = "Parallel efficiency (%)", mgp=c(3, 1, 0))
title(xlab = "# of pipes", mgp=c(2, 1, 0))

axis(side = 1, at = seq(0, 16, 2), labels = TRUE, line = -0.5)
axis(side = 2, at = seq(90, 100, 2), labels = TRUE, las=1)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
linetype <- c(1:4)
plotchar <- seq(0, 3, 1)
legend("top", c("cat|wc", "cat|awk", "grep|wc", "grep|awk"), horiz=T, bty="n",
    cex=1, pch=plotchar, lty=linetype, inset=c(0,0))

dev.off()
embed_fonts(as.character(args[1]))
