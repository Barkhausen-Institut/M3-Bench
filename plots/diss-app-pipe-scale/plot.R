library(extrafont)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.4
namescale <- 1.4
colors <- brewer.pal(n = 4, name = "Set1")

times <- read.table(as.character(args[2]), header=T, sep=" ")

print(as.numeric(times[1,]))

start <- if(args[3] == "1") 80 else 90
step  <- if(args[3] == "1") 5 else 2

pdf(as.character(args[1]), width=5, height=3)
par(mar=c(3.1,4.5,3.5,0))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

plot(as.numeric(rep(NA, 5)), ylim=c(start,100), type="o", pch=0, axes=FALSE, xlab="", ylab="")
abline(h=c(seq(start,100,step)), col="gray80")
par(new=T)

plot(c(1,2,4,8,16), as.numeric(times[1,]), ylim=c(start,100), type="o", col=colors[1], lwd=1.5, pch=0, lty=1, axes=F, ylab="", xlab="")
lines(c(1,2,4,8,16), as.numeric(times[2,]), ylim=c(start,100), type="o", col=colors[2], lwd=1.5, pch=1, lty=2)
lines(c(1,2,4,8,16), as.numeric(times[3,]), ylim=c(start,100), type="o", col=colors[3], lwd=1.5, pch=2, lty=3)
lines(c(1,2,4,8,16), as.numeric(times[4,]), ylim=c(start,100), type="o", col=colors[4], lwd=1.5, pch=3, lty=4)
title(ylab = "Paral. eff. (%)", mgp=c(3.2, 1, 0))
title(xlab = "# of pipes", mgp=c(2, 1, 0))

axis(side = 1, at = seq(0, 16, 2), labels = TRUE, line = -0.33)
axis(side = 2, at = seq(start, 100, step), labels = TRUE, las=1)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("cat|wc", "cat|awk"), horiz=T, bty="n",
    cex=namescale, pch=seq(0, 1, 1), lty=c(1:2), col=colors[1:2], lwd=1.5, inset=c(0,-.03))
legend("top", c("grep|wc", "grep|awk"), horiz=T, bty="n",
    cex=namescale, pch=seq(2, 3, 1), lty=c(3:4), col=colors[3:4], lwd=1.5, inset=c(0,.06))

dev.off()
embed_fonts(as.character(args[1]))
