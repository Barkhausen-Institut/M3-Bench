library(extrafont)
source("tools/helper.R")

scaling <- 2
args <- commandArgs(trailingOnly=TRUE)

# convert back to time (cycles / 3)
vs <- list()
for(i in 1:4) {
    vs[[i]] <- read.table(as.character(args[i + 1]), header=F, sep=" ") / (1000000 * 3)
}

pdf(as.character(args[1]), width=5, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow=TRUE),
    widths=c(1.65,1,1,1), heights=c(1,1))

par(mar=c(5.5,5.5,2,0))

barplot(
    as.matrix(vs[[1]]),
    beside=T,
    ylim=c(0, 11),
    mgp=c(3.5, 1, 0),
    las=2,
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names.arg=c("", ".25", "", "", "0.5", "", "", "1.0", "", "", "2.0", ""),
    sub="1 Accel.",
    axes=F,
    col=rep(gray.colors(3), 4)
)
title(ylab = "Time (ms)", mgp=c(3.5, 1, 0))
axis(2, at=seq(0, 10, 5), las=2)

for (i in 2:length(vs)) {
    par(mar=c(5.5,0,2,0))

    barplot(
        as.matrix(vs[[i]]),
        beside=T,
        axes=F,
        ylim=c(0, 11),
        mgp=c(3.5, 1, 0),
        las=2,
        space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
        names.arg=c("", ".25", "", "", "0.5", "", "", "1.0", "", "", "2.0", ""),
        sub=paste(2^(i - 1), "Accel."),
        col=rep(gray.colors(3), 4)
    )
}

dev.off()
embed_fonts(as.character(args[1]))
