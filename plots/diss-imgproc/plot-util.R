library(extrafont)
source("tools/helper.R")

scaling <- 2.5
args <- commandArgs(trailingOnly=TRUE)
colors <- gray.colors(2)

utils <- list()
for(i in 1:4) {
    utils[[i]] <- read.table(as.character(args[i + 1]), header=F, sep=" ")
}
zeros <- matrix(rep(c(NA), 2 * 1), nrow=2, ncol=1)

pdf(as.character(args[1]), width=3, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

layout(matrix(c(1,2,3,4), 1, 4, byrow=TRUE),
    widths=c(2.6,1,1,1), heights=c(1,1))

par(mar=c(3,6.5,4,0))

for (i in 1:length(utils)) {
    if(i > 1)
        par(mar=c(3,0,4,0))

    barplot(t(as.matrix(zeros)), beside=T, ylim=c(0,1), axes=F,
        space=c(0.1, 0.3), names.arg=rep("", 2))
    abline(h=c(seq(0, 1, 0.2)), col="gray80")

    barplot(
        as.matrix(utils[[i]]),
        beside=T,
        add=T,
        ylim=c(0, 1),
        mgp=c(3.5, 1, 0),
        las=1,
        space=c(0.1, 0.3),
        names.arg=i,
        col=colors,
        axes=F
    )
    if(i == 1) {
        title(ylab = "CPU time (rel)", mgp=c(4.5, 1, 0))
        axis(2, at=seq(0, 1, 0.2), las=2)
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Assist.", "Auton."), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,-.05), cex=scaling, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
