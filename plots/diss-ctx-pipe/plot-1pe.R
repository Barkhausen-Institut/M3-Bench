library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 1.6

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(2)

# convert back to time (cycles / 3)
times <- list()
stddevs <- list()
for(i in 1:4) {
    times[[i]]   <- read.table(as.character(args[i * 2]), header=F, sep=" ") / (1000000 * 3)
    stddevs[[i]] <- read.table(as.character(args[i * 2 + 1]), header=F, sep=" ") / (1000000 * 3)
}

print(times)
print(stddevs)

pdf(as.character(args[1]), width=5, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.8,1,1.1), heights=c(1,1))

par(mar=c(7.5,6,4,0))

plot <- barplot(t(as.matrix(times[[1]])), beside=T,
    ylim=c(0,25), ylab="", axes=F,
    space=c(0.5, 0, 0.5, 0, 0.5, 0, 0.5, 0),
    col=colors,
    cex.names=namescale, las=3, mgp=c(5, 0.5, 0),
    names.arg=c("512","1024","2048","4096"), sub="rand|wc")
axis(2, at = seq(0, 30, 5), las = 2)
title(ylab = "Time (ms)", mgp=c(4, 1, 0))
for(x in 1:4) {
    for(y in 1:2) {
        error.bar(plot[y,x], times[[1]][x,y], stddevs[[1]][x,y])
    }
}

names <- list("", "rand|sink", "cat|wc", "cat|sink")
for(i in 2:length(names)) {
    par(mar=c(7.5,0,4,0))

    plot <- barplot(t(as.matrix(times[[i]])), beside=T,
        ylim=c(0,25),
        space=c(0.5, 0, 0.5, 0, 0.5, 0, 0.5, 0),
        axes=F,
        col=colors,
        cex.names=namescale, las=3, mgp=c(5, 0.5, 0),
        names.arg=c("512","1024","2048","4096"), sub=names[[i]])
    for(x in 1:4) {
        for(y in 1:2) {
            error.bar(plot[y,x], times[[i]][x,y], stddevs[[i]][x,y])
        }
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Lx", "M3"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
