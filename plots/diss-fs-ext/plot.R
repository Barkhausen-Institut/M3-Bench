library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.25
namescale <- 1.25

times = read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000000 * 3)

pdf(as.character(args[1]), width=5, height=4, useDingbats=FALSE)
par(mar=c(4.1,4.3,2.1,1))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

plot(times$Read, ylim=c(0,20), type="o", pch=0, axes=FALSE, ylab="Time (ms)", xlab="Blocks per extent")
lines(times$Write, ylim=c(0,20), type="o", pch=1, lty="dashed")
lines(times$Copy, ylim=c(0,20), type="o", pch=2, lty="dotted")

axis(side = 1, at = 1:8, lab = c("2","4","8","16","32","64","128","256"))
axis(side = 2, at = seq(0, 20, by = 5), labels = TRUE)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
linetype <- c(1:3)
plotchar <- seq(0, 2, 1)
legend("top", c("Read", "Write", "Copy"), horiz=T, bty="n", cex=namescale, pch=plotchar, lty=linetype)

dev.off()
embed_fonts(as.character(args[1]))
