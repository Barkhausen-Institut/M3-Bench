library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.3

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

# convert back to time (cycles / 3)
times <- list()
for(i in 1:4) {
    times[[i]]   <- read.table(as.character(args[i + 1]), header=F, sep=" ")
}

pdf(as.character(args[1]), width=5, height=2)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.8,1,1.1), heights=c(1,1))

par(mar=c(5.5,5,4,0))

barplot(t(as.matrix(times[[1]])), beside=T, ylim=c(0,1), axes=F,
    space=rep(c(0.5, 0, 0, 0), 4), names.arg=rep("", 4))
abline(h=c(seq(0,1,.20)), col="gray80")

plot <- barplot(t(as.matrix(times[[1]])), beside=T, add=T,
    ylim=c(0,1), ylab="", axes=F,
    space=rep(c(0.5, 0, 0, 0), 4),
    col=colors,
    cex.names=namescale, las=3, mgp=c(2.5, 0.5, 0),
    names.arg=c("512","1024","2048","4096"), sub="rand|wc")
axis(2, at = seq(0, 1, .20), las = 2)
title(ylab = "Utilization", mgp=c(2.5, 1, 0))

names <- list("", "rand|sink", "cat|wc", "cat|sink")
for(i in 2:length(names)) {
    par(mar=c(5.5,0,4,0))

    barplot(t(as.matrix(times[[i]])), beside=T, ylim=c(0,1), axes=F,
        space=rep(c(0.5, 0, 0, 0), 4), names.arg=rep("", 4))
    abline(h=c(seq(0,1,.2)), col="gray80")

    plot <- barplot(t(as.matrix(times[[i]])), beside=T, add=T,
        ylim=c(0,1),
        space=rep(c(0.5, 0, 0, 0), 4),
        axes=F,
        col=colors,
        cex.names=namescale, las=3, mgp=c(2.5, 0.5, 0),
        names.arg=c("512","1024","2048","4096"), sub=names[[i]])
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,1.2,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("M3 (5)", "M3srv (3)", "M3all (2)", "M3all (1)"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
