library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 2
args <- commandArgs(trailingOnly=TRUE)
colors <- brewer.pal(n = 3, name = "Pastel1")

utils <- list()
sleep <- list()
for(i in 0:3) {
    utils[[i + 1]] <- read.table(as.character(args[i * 2 + 2]), header=F, sep=" ")
    sleep[[i + 1]] <- read.table(as.character(args[i * 2 + 3]), header=F, sep=" ")
}
zeros <- matrix(rep(c(NA), 12 * 1), nrow=12, ncol=1)

pdf(as.character(args[1]), width=5, height=3.2)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

layout(matrix(c(1,2,3,4), 1, 4, byrow=TRUE),
    widths=c(1.8,1,1,1), heights=c(1,1))

par(mar=c(9.5,6,4,0))

for (i in 1:length(utils)) {
    if(i > 1)
        par(mar=c(9.5,0,4,0))

    barplot(t(as.matrix(zeros)), beside=T, ylim=c(0,1), axes=F,
        space=c(0.3, 0.2), names.arg=rep("", 12))
    abline(h=c(seq(0, 1, 0.2)), col="gray80", lwd=2)

    barplot(
        as.matrix(utils[[i]]),
        beside=T,
        add=T,
        ylim=c(0, 1),
        mgp=c(7, 1, 0),
        las=2,
        space=rep(c(0.5, 0, 0), 4),
        names.arg=c("", "4GB/s", "", "", "2GB/s", "", "", "1GB/s", "", "", "0.5GB/s", ""),
        sub=paste(2^(i - 1), " Accel."),
        axes=F,
        col=rep(colors, 4)
    )
    if(i == 1) {
        title(ylab = "CPU time (rel)", mgp=c(4, 1, 0))
        axis(2, at=seq(0, 1, 0.2), las=2)
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Assisted", "Auto-Pipes", "Autonomous"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=scaling -.1, fill=colors, x.intersp=0.4)

dev.off()
embed_fonts(as.character(args[1]))
