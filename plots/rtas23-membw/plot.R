library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.5
namescale <- 1.5
colors <- brewer.pal(n = 3, name = "Pastel1")[1:2]

times   <- list()
for(i in 1:8) {
    times[[i]]   <- read.table(as.character(args[i + 1]), header=TRUE, sep=" ") / 1000000000
}

pdf(as.character(args[1]), width=5, height=2.2)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5,6,7,8), 1, 8, byrow = TRUE),
    widths=c(1.9,1,1,1,1,1,1,1), heights=c(1,1))

par(mar=c(6,4,1.5,0))

subs <- c("16M", "32M", "64M", "128M", "256M", "512M", "1G", "*")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(6,0,1.5,0))

    names <- c("FG", "BG")

    plot <- barplot(as.matrix(times[[i]]), beside=T, add=F,
        ylim=c(0,8),
        space=rep(0.15, length(names)), axes=F, width=rep(c(0.9), length(names)),
        col=colors, sub=subs[[i]],
        cex.names=namescale, las=3, mgp=c(3, .5, 0),
        names.arg=names)
    if(i == 1) {
        axis(2, at = seq(0,8,2), las = 2)
        title(ylab = "Throughput (GB/s)", mgp=c(2.5, 1, 0))
    }
}

dev.off()
embed_fonts(as.character(args[1]))
