library(extrafont)
source("tools/helper.R")

scaling <- 2
args <- commandArgs(trailingOnly=TRUE)

utils <- list()
sleep <- list()
for(i in 0:3) {
    utils[[i + 1]] <- read.table(as.character(args[i * 2 + 2]), header=F, sep=" ")
    sleep[[i + 1]] <- read.table(as.character(args[i * 2 + 3]), header=F, sep=" ")
}

pdf(as.character(args[1]), width=5, height=2.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow=TRUE),
    widths=c(1.8,1,1,1), heights=c(1,1))

par(mar=c(5.5,6,2,0))

print(sleep)

barplot(
    as.matrix(utils[[1]]),
    beside=T,
    border=NA,
    ylab="",
    ylim=c(0, 1),
    mgp=c(3.5, 1, 0),
    las=2,
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names.arg=c("", ".25", "", "", "0.5", "", "", "1.0", "", "", "2.0", ""),
    sub="1 Accel.",
    axes=F,
    col=rep(gray.colors(3), 4)
)
title(ylab = "CPU time (rel)", mgp=c(4, 1, 0))
axis(2, at=seq(0, 1, 0.5), las=2)

for (i in 2:length(utils)) {
    par(mar=c(5.5,0,2,0))

    barplot(
        as.matrix(utils[[i]]),
        beside=T,
        border=NA,
        ylim=c(0, 1),
        mgp=c(3.5, 1, 0),
        las=2,
        space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
        names.arg=c("", ".25", "", "", "0.5", "", "", "1.0", "", "", "2.0", ""),
        sub=paste(2^(i - 1), " Accel."),
        axes=F,
        col=rep(gray.colors(3), 4)
    )
}

dev.off()
embed_fonts(as.character(args[1]))
