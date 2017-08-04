library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 2

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(3)

wrtimes <- read.table(as.character(args[2]), header=TRUE, sep=" ") / 1000000
cptimes <- read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000
pitimes <- read.table(as.character(args[4]), header=TRUE, sep=" ") / 1000000
sqtimes <- read.table(as.character(args[5]), header=TRUE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.55,1,1,1), heights=c(1,1))

par(mar=c(9.5,5,4,2))

barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,10), space=c(0.3, 0.1, 0.1, 0.1), ylab="",
    col=colors,
    cex.names=namescale, las=3, mgp=c(6.5, 0.5, 0),
    names.arg=c("Linux","M3c-A","M3c-C","M3c-C*"), sub="tar")
title(ylab = "Time (M cycles)", mgp=c(3, 1, 0))
box(col = 'black')

par(mar=c(9.5,0,4,2))

barplot(as.matrix(cptimes), beside=F,
    ylim=c(0,10), space=c(0.3, 0.1, 0.1, 0.1), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(6.5, 0.5, 0),
    names.arg=c("Linux","M3c-A","M3c-C","M3c-C*"), sub="untar")
box(col = 'black')

par(mar=c(9.5,0,4,2))

barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,10), space=c(0.3, 0.1, 0.1, 0.1), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(6.5, 0.5, 0),
    names.arg=c("Linux","M3c-A","M3c-C","M3c-C*"), sub="find")
box(col = 'black')

par(mar=c(9.5,0,4,2))

barplot(as.matrix(sqtimes), beside=F,
    ylim=c(0,10), space=c(0.3, 0.1, 0.1, 0.1), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(6.5, 0.5, 0),
    names.arg=c("Linux","M3c-A","M3c-C","M3c-C*"), sub="sqlite")
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Application", "Data Xfers", "OS Overhead"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
