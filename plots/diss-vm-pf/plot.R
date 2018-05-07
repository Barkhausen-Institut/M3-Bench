library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.7
namescale <- 1.7

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

times   <- list()
stddevs <- list()
for(i in 1:4) {
    # convert back to time (cycles / 3)
    times[[i]]   <- read.table(as.character(args[i * 2]), header=TRUE, sep=" ") / (1000 * 3)
    stddevs[[i]] <- scan(args[i * 2 + 1]) / (1000 * 3)
    if(i >= 3) {
        times[[i]]   <- times[[i]][c(-1)]
        stddevs[[i]] <- stddevs[[i]][c(-1)]
    }
}

pdf(as.character(args[1]), width=6, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.45,1,0.8,0.8), heights=c(1,1))

par(mar=c(7,5,4,0))

barplot(as.matrix(times[[1]]), beside=F, ylim=c(0,10.21), axes=F,
    space=rep(0.2, 4), names.arg=rep("", 4))
abline(h=c(seq(0,10,2)), col="gray80")

plot <- barplot(as.matrix(times[[1]]), beside=F, add=T,
    ylim=c(0,10.21), space=rep(0.2, 4), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("Linux","M3-B","M3-C","M3-C*"), sub="Anon 1P")
axis(2, at = seq(0, 10, 2), las = 2)
title(ylab = "Time (µs)", mgp=c(3, 1, 0))
error.bar(plot, colSums(times[[1]]), stddevs[[1]])

subs <- c("File 1P", "Anon 4P", "File 4P")
for(i in 2:length(times)) {
    par(mar=c(7,0,4,0))

    if(i == 2)
        names <- c("Linux","M3-B","M3-C","M3-C*")
    else
        names <- c("M3-B","M3-C","M3-C*")

    barplot(as.matrix(times[[i]]), beside=F, ylim=c(0,10.21), axes=F,
        space=rep(0.2, length(names)), names.arg=rep("", length(names)))
    abline(h=c(seq(0,10,2)), col="gray80")

    plot <- barplot(as.matrix(times[[i]]), beside=F, add=T,
        ylim=c(0,10.21), space=rep(0.2, length(names)), ylab="", axes=F,
        col=colors,
        cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
        names.arg=names, sub=subs[[i - 1]])
    error.bar(plot, colSums(times[[i]]), stddevs[[i]])
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Kernel", "m3fs", "Pager", "VMA/DTU"), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
