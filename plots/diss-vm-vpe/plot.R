library(extrafont)
library(plotrix)
source("tools/helper.R")
options(warn=1)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2.2
namescale <- 2.2

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

# convert back to time (cycles / 3)
times  <- t(read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000000 * 3))
stddev <- t(read.table(as.character(args[3]), header=FALSE, sep=" ") / (1000000 * 3))

# cap values at 0.2
ctimes <- replace(times, T, pmin(0.22, times))

pdf(as.character(args[1]), width=10, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5), 1, 5, byrow = TRUE),
    widths=c(1.6,1,1,1,1), heights=c(1,1))

par(mar=c(8,6,2,0.5))

plot <- barplot(as.matrix(ctimes[1,]), beside=T,
    ylim=c(0,0.25), space=c(0.3, 0.3, 0.3, 0.3), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(5.5, 0.5, 0),
    names.arg=c("1 B", "2 MiB", "4 MiB", "8 MiB"), sub="Linux")
axis(2, at = seq(0, 0.22, 0.1), las = 2)
title(ylab = "Time (ms)", mgp=c(4, 1, 0))
error.bar(plot, ctimes[1,], stddev[1,])

par(mar=c(8,0,2,0.5))

plot <- barplot(as.matrix(ctimes[2,]), beside=T,
    ylim=c(0,0.25), space=c(0.3, 0.3, 0.3, 0.3), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(5.5, 0.5, 0),
    names.arg=c("1 B", "2 MiB", "4 MiB", "8 MiB"), sub="M3-A")
error.bar(plot, ctimes[2,], stddev[2,])

if(times[2,2] > ctimes[2,2]) {
    bar.break(plot, 2, 0.2, 0.004, 0.001)
    text(plot[2], 0.235, round(times[2,2],1), cex=2)
}
if(times[2,3] > ctimes[2,3]) {
    bar.break(plot, 3, 0.2, 0.004, 0.001)
    text(plot[3], 0.235, round(times[2,3],1), cex=2)
}
if(times[2,4] > ctimes[2,4]) {
    bar.break(plot, 4, 0.2, 0.004, 0.001)
    text(plot[4], 0.235, round(times[2,4],1), cex=2)
}

par(mar=c(8,0,2,0.5))

plot <- barplot(as.matrix(ctimes[3,]), beside=T,
    ylim=c(0,0.25), space=c(0.3, 0.3, 0.3, 0.3), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(5.5, 0.5, 0),
    names.arg=c("1 B", "2 MiB", "4 MiB", "8 MiB"), sub="M3-B")
error.bar(plot, ctimes[3,], stddev[3,])

par(mar=c(8,0,2,0.5))

plot <- barplot(as.matrix(ctimes[4,]), beside=T,
    ylim=c(0,0.25), space=c(0.3, 0.3, 0.3, 0.3), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(5.5, 0.5, 0),
    names.arg=c("1 B", "2 MiB", "4 MiB", "8 MiB"), sub="M3-C")
error.bar(plot, ctimes[4,], stddev[4,])

par(mar=c(8,0,2,0.5))

plot <- barplot(as.matrix(ctimes[5,]), beside=T,
    ylim=c(0,0.25), space=c(0.3, 0.3, 0.3, 0.3), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(5.5, 0.5, 0),
    names.arg=c("1 B", "2 MiB", "4 MiB", "8 MiB"), sub="M3-C*")
error.bar(plot, ctimes[5,], stddev[5,])

dev.off()
embed_fonts(as.character(args[1]))
