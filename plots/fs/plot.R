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

rdtimes <- read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000
rdstddev <- read.table(as.character(args[4]), header=FALSE, sep=" ") / 1000000

wrtimes <- read.table(as.character(args[5]), header=TRUE, sep=" ") / 1000000
wrstddev <- read.table(as.character(args[6]), header=FALSE, sep=" ") / 1000000

cptimes <- read.table(as.character(args[7]), header=TRUE, sep=" ") / 1000000
cpstddev <- read.table(as.character(args[8]), header=FALSE, sep=" ") / 1000000

pitimes <- read.table(as.character(args[9]), header=TRUE, sep=" ") / 1000000
pistddev <- read.table(as.character(args[10]), header=FALSE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.4,1,1,1), heights=c(1,1))

par(mar=c(6,5,2,2))

barx <- barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,11), space=c(0.3, 0, 0), axes=F, ylab="Time (M cycles)",
    cex.names=namescale,
    names.arg=c(osname,"Lx","Lx-$"), sub="Read")
error.bar(barx, colSums(rdtimes), as.double(rdstddev))
box(col = 'black')

cpvals <- as.matrix(cptimes)
cpvals <- ifelse(cpvals > 6, cpvals - 3, cpvals)
xat <- pretty(colSums(cpvals))
xat <- xat[xat != 8]
xlab <- ifelse(xat > 8, xat + 3, xat)
axis(side=2, at=xat, labels=xlab)
library(plotrix)
axis.break(axis=2, breakpos=8, style="gap")

par(mar=c(6,0,2,2))

barx <- barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,11), space=c(0.3, 0, 0), axes=F,
    cex.names=namescale,
    names.arg=c(osname,"Lx","Lx-$"), sub="Write")
error.bar(barx, colSums(wrtimes), as.double(wrstddev))
box(col = 'black')
axis.break(axis=2, breakpos=8, style="gap")

par(mar=c(6,0,2,2))

barx <- barplot(cpvals, beside=F,
    ylim=c(0,11), space=c(0.3, 0, 0), axes=F,
    cex.names=namescale,
    names.arg=c(osname,"Lx","Lx-$"), sub="Copy")
error.bar(barx, colSums(cpvals), as.double(cpstddev))
box(col = 'black')
axis.break(axis=2, breakpos=8, style="gap")

par(mar=c(6,0,2,2))

barx <- barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,11), space=c(0.3, 0, 0), axes=F,
    cex.names=namescale,
    names.arg=c(osname,"Lx","Lx-$"), sub="Pipe")
error.bar(barx, colSums(pitimes), as.double(pistddev))
box(col = 'black')
axis.break(axis=2, breakpos=8, style="gap")

legend("topright", c("Pagefaults", "Data transfers", "Remaining"), cex=1, fill=rev(gray.colors(3)))

par(mar=c(6,0,2,2))

dev.off()
