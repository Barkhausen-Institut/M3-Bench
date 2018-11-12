library(extrafont)
library(plotrix)
library(RColorBrewer)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.8
namescale <- 1.8
colors <- brewer.pal(n = 6, name = "Pastel1")

times <- list()
max <- list()
for(i in 1:4) {
    times[[i]] <- scan(args[i * 2])
    max[[i]] <- scan(args[i * 2 + 1])
}
zeros <- matrix(rep(c(NA), 6 * 1), nrow=6, ncol=1)

pdf(as.character(args[1]), width=4, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(2.35,1,1,1), heights=c(1,1))

par(mar=c(9.5,7.5,3.5,0))

subs <- c("Stencil ", "MD ", "FFT ", "SPMV ")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(9.5,0,3.5,0))

    barplot(t(as.matrix(zeros)), beside=F, ylim=c(100,1000000), axes=F, log="y",
        space=rep(c(0.3), 6), names.arg=rep("", 6))
    abline(h=c(10^(seq(log10(100), log10(1000000)))), col="gray80")

    plot <- barplot(times[[i]], beside=F, add=T, width=rep(c(0.9), 6),
        ylim=c(100,1000000), space=rep(c(0.3), 6), ylab="", axes=i == 1,
        col=colors, log="y",
        cex.names=namescale, las=1, mgp=c(0, 1, 0),
        sub=subs[[i]])
    if(i == 1)
        title(ylab = "Time (ns)", mgp=c(5.5, 1, 0))
    segments(plot - 0.2, max[[i]], plot + 0.2, max[[i]], lwd=2)
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("1", "4", "16", "64", "256", "N"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=namescale -.1, fill=colors, x.intersp=0.2, text.width=rep(.15, 6))

dev.off()
embed_fonts(as.character(args[1]))
