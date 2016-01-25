args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 1.8

osname <- as.character(args[2])
rdtimes <- read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000
wrtimes <- read.table(as.character(args[4]), header=TRUE, sep=" ") / 1000000
cptimes <- read.table(as.character(args[5]), header=TRUE, sep=" ") / 1000000
pitimes <- read.table(as.character(args[6]), header=TRUE, sep=" ") / 1000000
sqtimes <- read.table(as.character(args[7]), header=TRUE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=3.3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5), 1, 5, byrow = TRUE),
    widths=c(1.55,1,1,1,1), heights=c(1,1))

par(mar=c(7.5,5,2,2))

barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1, 0.1), ylab="",
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="cat+tr")
title(ylab = "Time (cycles)", mgp=c(3, 1, 0))
box(col = 'black')

legend("topleft", c("App", "Xfers", "OS"), cex=namescale, fill=rev(gray.colors(3)))

par(mar=c(7.5,0,2,2))

barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="tar")
box(col = 'black')

par(mar=c(7.5,0,2,2))

barplot(as.matrix(cptimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="untar")
box(col = 'black')

par(mar=c(7.5,0,2,2))

barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="find")
box(col = 'black')

par(mar=c(7.5,0,2,2))

barplot(as.matrix(sqtimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx","Lx-$"), sub="sqlite")
box(col = 'black')

par(mar=c(7.5,0,2,2))

dev.off()
