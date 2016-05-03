library(extrafont)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 1.8

colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")

osname <- "M³"
rdtimes <- read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000
wrtimes <- read.table(as.character(args[4]), header=TRUE, sep=" ") / 1000000
cptimes <- read.table(as.character(args[5]), header=TRUE, sep=" ") / 1000000
pitimes <- read.table(as.character(args[6]), header=TRUE, sep=" ") / 1000000
sqtimes <- read.table(as.character(args[7]), header=TRUE, sep=" ") / 1000000

# remove Lx-nocache
wrtimes <- wrtimes[c("M3","Lx")]
cptimes <- cptimes[c("M3","Lx")]
pitimes <- pitimes[c("M3","Lx")]
sqtimes <- sqtimes[c("M3","Lx")]

pdf(as.character(args[1]), width=7, height=3.8)
svg(paste(as.character(args[1]), ".svg"), width=7, height=3.8)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.45,1,1,1), heights=c(1,1))

par(mar=c(7.5,5,4,2))

barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1), ylab="",
    col=colors,
    cex.names=namescale,
    names.arg=c(osname,"Linux"), sub="tar")
title(ylab = "Time (Million cycles)", mgp=c(3, 1, 0))
box(col = 'black')

par(mar=c(7.5,0,4,2))

barplot(as.matrix(cptimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1), axes=F,
    col=colors,
    cex.names=namescale,
    names.arg=c(osname,"Linux"), sub="untar")
axis(side=2, at=c(0,1,2,3,4,5,6), labels=rep("",7))
box(col = 'black')

par(mar=c(7.5,0,4,2))

barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,6), space=c(0.3, 0.1), axes=F,
    col=colors,
    cex.names=namescale,
    names.arg=c(osname,"Linux"), sub="find")
axis(side=2, at=c(0,1,2,3,4,5,6), labels=rep("",7))
box(col = 'black')

par(mar=c(7.5,0,4,2))

barplot(as.matrix(sqtimes), beside=F,
    col=colors,
    ylim=c(0,6), space=c(0.3, 0.1), axes=F,
    cex.names=namescale,
    names.arg=c(osname,"Linux"), sub="sqlite")
axis(side=2, at=c(0,1,2,3,4,5,6), labels=rep("",7))
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("App", "Xfers", "OS"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
