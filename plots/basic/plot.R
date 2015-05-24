error.bar <- function(mp, means, stddevs) {
    stDevs <- matrix(stddevs, length(stddevs))
    # Plot the vertical lines of the error bars
    # The vertical bars are plotted at the midpoints
    segments(mp, means - stDevs, mp, means + stDevs, lwd=1)
    # Now plot the horizontal bounds for the error bars
    # 1. The lower bar
    segments(mp - 0.1, means - stDevs, mp + 0.1, means - stDevs, lwd=1)
    # 2. The upper bar
    segments(mp - 0.1, means + stDevs, mp + 0.1, means + stDevs, lwd=1)
}

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.15

sctimes <- read.table(as.character(args[2]), header=TRUE, sep=" ")
scstddevs <- read.table(as.character(args[3]), header=FALSE, sep=" ")

thtimes <- read.table(as.character(args[4]), header=TRUE, sep=" ")
thstddevs <- read.table(as.character(args[5]), header=FALSE, sep=" ")

extimes <- read.table(as.character(args[6]), header=TRUE, sep=" ")
exstddevs <- read.table(as.character(args[7]), header=FALSE, sep=" ")

pdf(as.character(args[1]), width=7, height=5)

layout(matrix(c(1,2,3), 1, 3, byrow = TRUE),
    widths=c(1,1.3,1), heights=c(1,1))

par(mar=c(3,5,3,3))

barx <- barplot(as.matrix(sctimes), col=gray.colors(2), ylab="Time (cycles)",
    space=0, ylim=c(0,1000),
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("               Syscall", ""))

error.bar(barx, colSums(sctimes), as.integer(scstddevs))
box(col = 'black')

par(mar=c(3,2,3,2))

barx <- barplot(as.matrix(thtimes), col=gray.colors(2), axes = FALSE,
    space=c(0, 0), ylim=c(0,200000),
    cex.names=namescale)

error.bar(barx, colSums(thtimes), as.integer(thstddevs))
axis(side = 2, labels = TRUE, cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)
box(col = 'black')

par(mar=c(3,2,3,1))

barx <- barplot(as.matrix(extimes), col=gray.colors(2), axes = FALSE,
    space=c(0, 0), ylim=c(0,700000),
    cex.names=namescale)

legend("topright", c("Remaining", "Cache-misses"), cex=1, fill=gray.colors(2))
error.bar(barx, colSums(extimes), as.integer(exstddevs))
axis(side = 2, labels = TRUE, cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)
box(col = 'black')

dev.off()
