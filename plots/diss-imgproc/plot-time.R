library(extrafont)
source("tools/helper.R")

scaling <- 2.5
args <- commandArgs(trailingOnly=TRUE)
colors <- gray.colors(2)

# convert back to time (cycles / 3)
vs <- list()
for(i in 1:4) {
    vs[[i]] <- read.table(as.character(args[i + 1]), header=F, sep=" ") / (1000000 * 3)
}
zeros <- matrix(rep(c(NA), 2 * 1), nrow=2, ncol=1)

pdf(as.character(args[1]), width=3, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow=TRUE),
    widths=c(2.4,1,1,1), heights=c(1,1))

par(mar=c(3,6,4,0))

for (i in 1:length(vs)) {
    if(i > 1)
        par(mar=c(3,0,4,0))

    barplot(t(as.matrix(zeros)), beside=T, ylim=c(0,80), axes=F,
        space=c(0.1, 0.3), names.arg=rep("", 2))
    abline(h=c(seq(0, 80, 15)), col="gray80")

    barplot(
        as.matrix(vs[[i]]),
        beside=T,
        axes=F,
        add=T,
        ylim=c(0, 80),
        mgp=c(3.5, 1, 0),
        las=1,
        space=c(0.1, 0.3),
        names.arg=i,
        col=colors
    )
    if(i == 1) {
        title(ylab = "Runtime (ms)", mgp=c(4, 1, 0))
        axis(2, at=seq(0, 80, 15), las=2)
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Assist.", "Auton."), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,-.05), cex=scaling, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
