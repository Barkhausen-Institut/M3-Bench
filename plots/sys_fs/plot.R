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
scaling <- 2.2
namescale <- 2.2

osname <- as.character(args[2])

sctimes <- read.table(as.character(args[3]), header=TRUE, sep=" ")
scstddevs <- read.table(as.character(args[4]), header=FALSE, sep=" ")

rdtimes <- read.table(as.character(args[5]), header=TRUE, sep=" ")    / 1000000
rdstddev <- read.table(as.character(args[6]), header=FALSE, sep=" ")  / 1000000

wrtimes <- read.table(as.character(args[7]), header=TRUE, sep=" ")    / 1000000
wrstddev <- read.table(as.character(args[8]), header=FALSE, sep=" ")  / 1000000

pitimes <- read.table(as.character(args[9]), header=TRUE, sep=" ")    / 1000000
pistddev <- read.table(as.character(args[10]), header=FALSE, sep=" ")  / 1000000

pdf(as.character(args[1]), width=8, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.5,1.5,1.1,1.1), heights=c(1,1))

par(mar=c(6,5,2,2))

barx <- barplot(as.matrix(sctimes), beside=F,
    ylim=c(0.0,500), space=c(0.3, 0.1, 0.1), axes=T, ylab="Time (cycles)",
    cex.names=namescale,
    names.arg=c(osname,"B","C"), sub="Syscall")

error.bar(barx, colSums(sctimes), as.double(scstddevs))
box(col = 'black')

par(mar=c(6,4.5,2,2))

barx <- barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,9), space=c(0.3, 0.1, 0.1), axes=T, ylab="Time (M cycles)",
    cex.names=namescale,
    names.arg=c(osname,"B","C"), sub="Read")
error.bar(barx, colSums(rdtimes), as.double(rdstddev))
box(col = 'black')

par(mar=c(6,0,2,2))

barx <- barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,9), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale,
    names.arg=c(osname,"B","C"), sub="Write")
error.bar(barx, colSums(wrtimes), as.double(wrstddev))
box(col = 'black')

legend("topright", c("Xfers", "Other"), cex=namescale, fill=rev(gray.colors(2)))

par(mar=c(6,0,2,2))

barx <- barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,9), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale,
    names.arg=c(osname,"B","C"), sub="Pipe")
error.bar(barx, colSums(pitimes), as.double(pistddev))
box(col = 'black')

par(mar=c(6,0,2,2))

dev.off()
