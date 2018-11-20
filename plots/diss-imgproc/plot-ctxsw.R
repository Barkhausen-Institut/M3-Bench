library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

scaling <- 1.9
args <- commandArgs(trailingOnly=TRUE)
colors <- brewer.pal(n = 3, name = "Pastel1")

overhead <- list()
for(i in 1:4) {
    overhead[[i]] <- read.table(as.character(args[i + 1]), header=F, sep=" ")
}
zeros <- matrix(rep(c(NA), 3 * 1), nrow=3, ncol=1)

pdf(as.character(args[1]), width=3, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

layout(matrix(c(1,2,3,4), 1, 4, byrow=TRUE),
    widths=c(2.5,1,1,1), heights=c(1,1))

par(mar=c(2.5,6.2,3,0))

for (i in 1:length(overhead)) {
    if(i > 1)
        par(mar=c(2.5,0,3,0))

    barplot(t(as.matrix(zeros)), beside=T, ylim=c(0.98,1.082), axes=F, xpd=F,
        space=c(0.1, 0.3), names.arg=rep("", 3))
    abline(h=c(seq(0.98, 1.08, 0.02)), col="gray80", lwd=2)

    barplot(
        as.matrix(overhead[[i]]),
        beside=T,
        add=T,
        xpd=F,
        ylim=c(0.98,1.082),
        mgp=c(3.5, 1, 0),
        las=1,
        space=c(0.1, 0.3),
        names.arg=i,
        col=colors,
        axes=F
    )
    if(i == 1) {
        title(ylab = "Runtime (rel)", mgp=c(4.5, 1, 0))
        axis(2, at=seq(0.98, 1.08, 0.02), las=2)
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("1ms", "2ms", "4ms"), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,-.05), cex=scaling, fill=colors, x.intersp=0.3)

dev.off()
embed_fonts(as.character(args[1]))
