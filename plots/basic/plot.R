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

osname <- as.character(args[2])

sctimes <- read.table(as.character(args[3]), header=TRUE, sep=" ")      / 1000
scstddevs <- read.table(as.character(args[4]), header=FALSE, sep=" ")   / 1000

thtimes <- read.table(as.character(args[5]), header=TRUE, sep=" ")      / 1000
thstddevs <- read.table(as.character(args[6]), header=FALSE, sep=" ")   / 1000

extimes <- read.table(as.character(args[7]), header=TRUE, sep=" ")      / 1000
exstddevs <- read.table(as.character(args[8]), header=FALSE, sep=" ")   / 1000

pdf(as.character(args[1]), width=7, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3), 1, 3, byrow = TRUE),
    widths=c(1,1.05,1), heights=c(1,1))

par(mar=c(3,5,3,3))

barx <- barplot(as.matrix(sctimes), col=gray.colors(2), ylab="Time (K cycles)",
    space=0, ylim=c(0.0,0.5), names.arg=c(paste(osname,"sys",sep="."),"Lx.sys"),
    cex.names=namescale)

error.bar(barx, colSums(sctimes), as.double(scstddevs))
box(col = 'black')
legend("topleft", c("Cache-misses", "Remaining"), cex=1, fill=rev(gray.colors(2)))

par(mar=c(3,2,3,2))

barx <- barplot(as.matrix(thtimes), col=gray.colors(2), axes = FALSE,
    space=c(0, 0), ylim=c(0,170), names.arg=c(paste(osname,"run",sep="."),"Lx.clone","Lx.fork"),
    cex.names=namescale)

error.bar(barx, colSums(thtimes), as.integer(thstddevs))
axis(side = 2, labels = TRUE)
box(col = 'black')

par(mar=c(3,2,3,1))

barx <- barplot(as.matrix(extimes), col=gray.colors(2), axes = FALSE,
    space=c(0, 0), ylim=c(0,600), names.arg=c(paste(osname,"exec",sep="."),"Lx.f+e","Lx.vf+e"),
    cex.names=namescale)

error.bar(barx, colSums(extimes), as.integer(exstddevs))
axis(side = 2, labels = TRUE)
box(col = 'black')

dev.off()
