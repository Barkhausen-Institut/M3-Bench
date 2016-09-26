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
scaling <- 2
namescale <- 1.8

randwc         <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" ") / 1000000)
randsink        <- as.data.table(read.table(as.character(args[4]), header=TRUE, sep=" ") / 1000000)
catwc       <- as.data.table(read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000)
catsink      <- as.data.table(read.table(as.character(args[5]), header=TRUE, sep=" ") / 1000000)

randwcsd       <- copy(randwc)
randwcsd       <- randwcsd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]
randwcsd       <- randwcsd[1]
randsinksd      <- copy(randsink)
randsinksd      <- randsinksd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]
randsinksd       <- randsinksd[1]
catwcsd     <- copy(catwc)
catwcsd     <- catwcsd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]
catwcsd       <- catwcsd[1]
catsinksd    <- copy(catsink)
catsinksd    <- catsinksd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]
catsinksd       <- catsinksd[1]

randwctimes    <- randwc[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]
randsinktimes   <- randsink[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]
catwctimes  <- catwc[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]
catsinktimes <- catsink[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]

pdf(as.character(args[1]), width=7.5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.5,1,1,1), heights=c(1,1))

par(mar=c(7.5,5,4,2))

barx <- barplot(as.matrix(randwctimes), beside=F,
    ylim=c(0,11), space=c(0.3, 0.1), ylab="",
    cex.names=namescale, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Share"), sub="rand|wc")
title(ylab = "Time (M cycles)", mgp=c(3, 1, 0))
box(col = 'black')
error.bar(barx, colSums(randwctimes), as.double(randwcsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(randsinktimes), beside=F,
    ylim=c(0,11), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Share"), sub="rand|sink")
box(col = 'black')
error.bar(barx, colSums(randsinktimes), as.double(randsinksd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(catwctimes), beside=F,
    ylim=c(0,11), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Share"), sub="cat|wc")
box(col = 'black')
error.bar(barx, colSums(catwctimes), as.double(catwcsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(catsinktimes), beside=F,
    ylim=c(0,11), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Share"), sub="cat|sink")
box(col = 'black')
error.bar(barx, colSums(catsinktimes), as.double(catsinksd))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Compute", "Transfers"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(gray.colors(2)))

dev.off()
embed_fonts(as.character(args[1]))
