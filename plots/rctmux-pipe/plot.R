library(extrafont)
library(data.table)

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
scaling <- 1.5
namescale <- 1.1

randwc          <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" "))
randsink        <- as.data.table(read.table(as.character(args[3]), header=TRUE, sep=" "))
catwc           <- as.data.table(read.table(as.character(args[4]), header=TRUE, sep=" "))
catsink         <- as.data.table(read.table(as.character(args[5]), header=TRUE, sep=" "))
catwcfs         <- as.data.table(read.table(as.character(args[6]), header=TRUE, sep=" "))

randwcsd        <- copy(randwc)
randwcsd        <- randwcsd[ ,`:=`("ratio" = NULL)]
randwcsd        <- randwcsd[1]
randsinksd      <- copy(randsink)
randsinksd      <- randsinksd[ ,`:=`("ratio" = NULL)]
randsinksd      <- randsinksd[1]
catwcsd         <- copy(catwc)
catwcsd         <- catwcsd[ ,`:=`("ratio" = NULL)]
catwcsd         <- catwcsd[1]
catsinksd       <- copy(catsink)
catsinksd       <- catsinksd[ ,`:=`("ratio" = NULL)]
catsinksd       <- catsinksd[1]
catwcfssd       <- copy(catwcfs)
catwcfssd       <- catwcfssd[ ,`:=`("ratio" = NULL)]
catwcfssd       <- catwcfssd[1]

randwctimes     <- randwc[ ,`:=`("stddev" = NULL)]
randsinktimes   <- randsink[ ,`:=`("stddev" = NULL)]
catwctimes      <- catwc[ ,`:=`("stddev" = NULL)]
catsinktimes    <- catsink[ ,`:=`("stddev" = NULL)]
catwcfstimes    <- catwcfs[ ,`:=`("stddev" = NULL)]

pdf(as.character(args[1]), width=7.5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5), 1, 5, byrow = TRUE),
    widths=c(1.5,1,1,1,1), heights=c(1,1))

par(mar=c(7.5,5,4,2))

barx <- barplot(as.matrix(randwctimes), beside=T,
    ylim=c(0,1), ylab="", space=0.1,
    cex.names=namescale, names.arg="",
    sub="rand|wc")
title(ylab = "Time (relative to baseline)", mgp=c(3, 1, 0))
box(col = 'black')
error.bar(barx, colSums(randwctimes), as.double(randwcsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(randsinktimes), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=namescale, names.arg="",
    sub="rand|sink")
box(col = 'black')
error.bar(barx, colSums(randsinktimes), as.double(randsinksd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(catwctimes), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=namescale, names.arg="",
    sub="cat|wc")
box(col = 'black')
error.bar(barx, colSums(catwctimes), as.double(catwcsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(catsinktimes), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=namescale, names.arg="",
    sub="cat|sink")
box(col = 'black')
error.bar(barx, colSums(catsinktimes), as.double(catsinksd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(catwcfstimes), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=namescale, names.arg="",
    sub="fs:cat|wc")
box(col = 'black')
error.bar(barx, colSums(catwcfstimes), as.double(catwcfssd))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("64 KiB","128 KiB","256 KiB","512 KiB", "1024 KiB"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=gray.colors(5))

dev.off()
embed_fonts(as.character(args[1]))
