library(extrafont)
library(data.table)
source("tools/helper.R")


args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.8
namescale <- 1.4

tar         <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" "))
untar       <- as.data.table(read.table(as.character(args[3]), header=TRUE, sep=" "))
find        <- as.data.table(read.table(as.character(args[4]), header=TRUE, sep=" "))
sqlite      <- as.data.table(read.table(as.character(args[5]), header=TRUE, sep=" "))

tarsd       <- copy(tar)
tarsd       <- tarsd[ ,`:=`("ratio" = NULL)]
untarsd     <- copy(untar)
untarsd     <- untarsd[ ,`:=`("ratio" = NULL)]
findsd      <- copy(find)
findsd      <- findsd[ ,`:=`("ratio" = NULL)]
sqlitesd    <- copy(sqlite)
sqlitesd    <- sqlitesd[ ,`:=`("ratio" = NULL)]

tartimes    <- tar[ ,`:=`("stddev" = NULL)]
untartimes  <- untar[ ,`:=`("stddev" = NULL)]
findtimes   <- find[ ,`:=`("stddev" = NULL)]
sqlitetimes <- sqlite[ ,`:=`("stddev" = NULL)]

pdf(as.character(args[1]), width=4, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.8,1,1,1), heights=c(1,1))

par(mar=c(7.5,5,4,2))

barx <- barplot(as.matrix(tartimes), beside=T,
    ylim=c(0,1), ylab="", space=0.1,
    cex.names=namescale, names.arg="",
    sub="tar")
title(ylab = "Time (relative to baseline)", mgp=c(3, 1, 0))
box(col = 'black')
error.bar(barx, colSums(tartimes), as.double(tarsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(untartimes), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=namescale, names.arg="",
    sub="untar")
box(col = 'black')
error.bar(barx, colSums(untartimes), as.double(untarsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(findtimes), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=namescale, names.arg="",
    sub="find")
box(col = 'black')
error.bar(barx, colSums(findtimes), as.double(findsd))

par(mar=c(7.5,0,4,2))

barplot(as.matrix(sqlitetimes), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=namescale, names.arg="",
    sub="sqlite")
box(col = 'black')
error.bar(barx, colSums(sqlitetimes), as.double(sqlitesd))

dev.off()
embed_fonts(as.character(args[1]))
