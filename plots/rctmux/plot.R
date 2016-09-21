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

tar         <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" ") / 1000000)
untar       <- as.data.table(read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000)
find        <- as.data.table(read.table(as.character(args[4]), header=TRUE, sep=" ") / 1000000)
sqlite      <- as.data.table(read.table(as.character(args[5]), header=TRUE, sep=" ") / 1000000)

tarsd       <- copy(tar)
tarsd       <- tarsd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]
untarsd     <- copy(untar)
untarsd     <- untarsd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]
findsd      <- copy(find)
findsd      <- findsd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]
sqlitesd    <- copy(sqlite)
sqlitesd    <- sqlitesd[ ,`:=`("Alone" = NULL, "Shared" = NULL)]

tartimes    <- tar[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]
untartimes  <- untar[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]
findtimes   <- find[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]
sqlitetimes <- sqlite[ ,`:=`("AloneSD" = NULL, "SharedSD" = NULL)]

pdf(as.character(args[1]), width=7, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.55,1,1,1), heights=c(1,1))

par(mar=c(7.5,5,4,2))

barx <- barplot(as.matrix(tartimes), beside=F,
    ylim=c(0,15), space=c(0.3, 0.1), ylab="",
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Shared"), sub="tar")
title(ylab = "Time (M cycles)", mgp=c(3, 1, 0))
box(col = 'black')
error.bar(barx, colSums(tartimes), as.double(tarsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(untartimes), beside=F,
    ylim=c(0,15), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Shared"), sub="untar")
box(col = 'black')
error.bar(barx, colSums(untartimes), as.double(untarsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(findtimes), beside=F,
    ylim=c(0,15), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Shared"), sub="find")
box(col = 'black')
error.bar(barx, colSums(findtimes), as.double(findsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(sqlitetimes), beside=F,
    ylim=c(0,15), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("Alone","Shared"), sub="sqlite")
box(col = 'black')
error.bar(barx, colSums(sqlitetimes), as.double(sqlitesd))

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("App", "Xfers", "OS"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(gray.colors(3)))

dev.off()
embed_fonts(as.character(args[1]))
