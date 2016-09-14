library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 1.8

osname <- as.character(args[2])
rdtimes <- read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000
wrtimes <- read.table(as.character(args[4]), header=TRUE, sep=" ") / 1000000
cptimes <- read.table(as.character(args[5]), header=TRUE, sep=" ") / 1000000
pitimes <- read.table(as.character(args[6]), header=TRUE, sep=" ") / 1000000
sqtimes <- read.table(as.character(args[7]), header=TRUE, sep=" ") / 1000000
wctimes <- read.table(as.character(args[8]), header=TRUE, sep=" ") / 1000000
grtimes <- read.table(as.character(args[9]), header=TRUE, sep=" ") / 1000000
shtimes <- read.table(as.character(args[10]), header=TRUE, sep=" ") / 1000000
sotimes <- read.table(as.character(args[11]), header=TRUE, sep=" ") / 1000000
tatimes <- read.table(as.character(args[12]), header=TRUE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5,6,7,8,9,10), 1, 10, byrow = TRUE),
    widths=c(2,1,1,1,1,1,1,1,1,1), heights=c(1,1))

par(mar=c(7.5,5,4,0.5))

barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), ylab="",
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="cat+tr")
title(ylab = "Time (M cycles)", mgp=c(3, 1, 0))
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="tar")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(cptimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="untar")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="find")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(sqtimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="sqlite")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(wctimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="wc")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(grtimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="grep")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(shtimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="sha")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(sotimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="sort")
box(col = 'black')

par(mar=c(7.5,0,4,0.5))

barplot(as.matrix(tatimes), beside=F,
    ylim=c(0,8), space=c(0.3, 0.1), axes=F,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c(osname,"Lx"), sub="tail")
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("App", "Xfers", "OS"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(gray.colors(3)))

dev.off()
embed_fonts(as.character(args[1]))
