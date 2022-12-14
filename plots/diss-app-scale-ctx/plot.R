library(extrafont)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.4
namescale <- 1.4
colors <- brewer.pal(n = 7, name = "Set1")
# the yellow color is barely visible
colors[6] <- brewer.pal(n = 4, name = "Set2")[4]

ratios <- read.table(as.character(args[2]), header=F, sep=" ")

print(ratios)

cairo_pdf(as.character(args[1]), width=5, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

par(mar=c(3.1,4.5,3.5,0))

plot(as.numeric(rep(NA, 7)), ylim=c(0,100), type="o", pch=0, lty=1, axes=FALSE, ylab="", xlab="")
abline(h=c(seq(0,100,25)), col="gray80", lwd=2)
par(new=T)

for(i in 1:7) {
    if(i == 1)
        plot(as.numeric(ratios[i,]), ylim=c(0,100), type="o", col=colors[i], lwd=1.5, pch=0, lty=i, axes=FALSE, ylab="", xlab="")
    else
        lines(as.numeric(ratios[i,]), ylim=c(0,100), type="o", col=colors[i], lwd=1.5, pch=i - 1, lty=i)
}

axis(side = 1, at = 1:6, lab = c("1","2","4","8","16","32"), line=-0.33)
axis(side = 2, at = seq(0, 100, 25), labels = TRUE, las=1)
title(ylab = "Paral. ef\u200Cf. (%)", mgp=c(3.2, 1, 0))
title(xlab = "# of applications", mgp=c(2, 1, 0))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("tar","untar","f\u200Cind","sqlite"),
    horiz=T, bty="n",
    cex=namescale, pch=seq(0, 3, 1), lty=c(1:4), col=colors[1:4], lwd=1.5, inset=c(0,-.03))
legend("top", c("leveldb","shasum","sort"),
    horiz=T, bty="n",
    cex=namescale, pch=seq(4, 7, 1), lty=c(5:7), col=colors[5:7], lwd=1.5, inset=c(0,.06))

dev.off()
embedFonts(as.character(args[1]))
