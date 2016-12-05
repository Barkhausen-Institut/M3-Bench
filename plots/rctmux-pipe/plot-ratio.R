library(extrafont)
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2.4
namescale <- 2

randwc          <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" "))
randsink        <- as.data.table(read.table(as.character(args[3]), header=TRUE, sep=" "))
catwc           <- as.data.table(read.table(as.character(args[4]), header=TRUE, sep=" "))
catsink         <- as.data.table(read.table(as.character(args[5]), header=TRUE, sep=" "))
catwcfs         <- as.data.table(read.table(as.character(args[6]), header=TRUE, sep=" "))

pdf(as.character(args[1]), width=7.5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5), 1, 5, byrow = TRUE),
    widths=c(1.5,1,1,1,1), heights=c(1,1))

par(mar=c(2.8,5.5,4.8,0.8))

barx <- barplot(as.matrix(randwc), beside=T,
    ylim=c(0,1), ylab="", space=0.1,
    cex.names=scaling, names.arg="rand|wc")
title(ylab = "Time (relative to baseline)", mgp=c(3, 1, 0))
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(randsink), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=scaling, names.arg="rand|sink")
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(catwc), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=scaling, names.arg="cat|wc")
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(catsink), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=scaling, names.arg="cat|sink")
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(catwcfs), beside=T,
    ylim=c(0,1), axes=F, space=0.1,
    cex.names=scaling, names.arg="fs:cat|wc")
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("64 KiB","128 KiB","256 KiB","512 KiB", "1024 KiB"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=gray.colors(5))

dev.off()
embed_fonts(as.character(args[1]))
