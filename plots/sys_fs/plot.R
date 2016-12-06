library(extrafont)
source("tools/helper.R")

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

pdf(as.character(args[1]), width=8, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.5,1.5,1.1,1.1), heights=c(1,1))

par(mar=c(8,5,2,2))

barx <- barplot(as.matrix(sctimes), beside=F,
    ylim=c(0.0,500), space=c(0.3, 0.1, 0.1), axes=T, ylab="",
    cex.names=namescale, las=3, mgp=c(5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="Syscall")
title(ylab = "Time (cycles)", mgp=c(3, 1, 0))

error.bar(barx, colSums(sctimes), as.double(scstddevs))
box(col = 'black')

par(mar=c(8,4.5,2,2))

barx <- barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,7), space=c(0.3, 0.1, 0.1), axes=T, ylab="",
    cex.names=namescale, las=3, mgp=c(5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="Read")
title(ylab = "Time (M cycles)", mgp=c(3, 1, 0))

error.bar(barx, colSums(rdtimes), as.double(rdstddev))
box(col = 'black')

par(mar=c(8,0,2,2))

barx <- barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,7), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="Write")
error.bar(barx, colSums(wrtimes), as.double(wrstddev))
box(col = 'black')

legend("topright", c("Xfers", "Other"), cex=namescale, fill=rev(gray.colors(2)))

par(mar=c(8,0,2,2))

barx <- barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,7), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="Pipe")
error.bar(barx, colSums(pitimes), as.double(pistddev))
box(col = 'black')

par(mar=c(6,0,2,2))

dev.off()
embed_fonts(as.character(args[1]))
