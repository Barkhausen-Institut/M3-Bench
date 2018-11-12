library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.9
colors <- brewer.pal(n = 3, name = "Pastel1")

times <- list()
for(i in 1:4) {
    times[[i]] <- scan(args[i + 1])
}
zeros <- matrix(rep(c(NA), 3 * 1), nrow=3, ncol=1)

pdf(as.character(args[1]), width=3, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling - .1, family="Ubuntu")

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(2.5,1,1,1), heights=c(1,1))

par(mar=c(2.5,6.2,3,0))

subs <- c("Sten", "MD", "FFT", "SPMV")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(2.5,0,3,0))

    barplot(t(as.matrix(zeros)), beside=F, ylim=c(0.98,1.08), axes=F, xpd=F,
        space=0.1, names.arg=rep("", 3))
    abline(h=c(seq(0.98,1.08,0.02)), col="gray80")

    plot <- barplot(times[[i]], beside=F, add=T, width=rep(c(0.9), 3), xpd=F,
        ylim=c(0.98,1.08), axes=F,
        space=0.1,
        col=colors,
        las=3, mgp=c(0, 0.5, 0),
        sub=subs[[i]])
    if(i == 1) {
        axis(2, at = seq(0.98, 1.08, 0.02), las = 2)
        title(ylab = "Runtime (rel)", mgp=c(4.5, 1, 0))
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("1ms", "2ms", "4ms"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-.05), cex=scaling, fill=colors, x.intersp=0.3)

dev.off()
embed_fonts(as.character(args[1]))
