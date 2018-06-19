library(extrafont)
source("tools/helper.R")

scaling <- 2
args <- commandArgs(trailingOnly=TRUE)

# convert back to time (cycles / 3)
vs <- list()
for(i in 1:4) {
    vs[[i]] <- read.table(as.character(args[i + 1]), header=F, sep=" ") / (1000000 * 3)
}
zeros <- matrix(rep(c(NA), 12 * 1), nrow=12, ncol=1)

pdf(as.character(args[1]), width=5, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow=TRUE),
    widths=c(1.65,1,1,1), heights=c(1,1))

par(mar=c(5.5,5.5,2,0))

for (i in 1:length(vs)) {
    if(i > 1)
        par(mar=c(5.5,0,2,0))

    barplot(t(as.matrix(zeros)), beside=T, ylim=c(0,11), axes=F,
        space=c(0.3, 0.2), names.arg=rep("", 12))
    abline(h=c(seq(0, 10, 2)), col="gray80")

    barplot(
        as.matrix(vs[[i]]),
        beside=T,
        axes=F,
        add=T,
        ylim=c(0, 11),
        mgp=c(3.5, 1, 0),
        las=2,
        space=rep(c(0.5, 0, 0), 4),
        names.arg=c("", ".25", "", "", "0.5", "", "", "1.0", "", "", "2.0", ""),
        sub=paste(2^(i - 1), "Accel."),
        col=rep(gray.colors(3), 4)
    )
    if(i == 1) {
        title(ylab = "Time (ms)", mgp=c(3.5, 1, 0))
        axis(2, at=seq(0, 10, 2), las=2)
    }
}

dev.off()
embed_fonts(as.character(args[1]))
