library(extrafont)
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2.4
namescale <- 2

randwc          <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" ")) / 1000000
randsink        <- as.data.table(read.table(as.character(args[3]), header=TRUE, sep=" ")) / 1000000
catwc           <- as.data.table(read.table(as.character(args[4]), header=TRUE, sep=" ")) / 1000000
catsink         <- as.data.table(read.table(as.character(args[5]), header=TRUE, sep=" ")) / 1000000
catwcfs         <- as.data.table(read.table(as.character(args[6]), header=TRUE, sep=" ")) / 1000000

pdf(as.character(args[1]), width=7.5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5), 1, 5, byrow = TRUE),
    widths=c(1.5,1,1,1,1), heights=c(1,1))

par(mar=c(2.8,5.5,4.8,0.8))

barspace = c(0.1, 0, 1, 0, 1, 0, 1, 0, 1, 0)
barcols = c("#4D4D4D", "#4D4D4D",
            "#888888", "#888888",
            "#AEAEAE", "#AEAEAE",
            "#CCCCCC", "#CCCCCC",
            "#E6E6E6", "#E6E6E6")

barplot(as.matrix(randwc),
    ylim=c(0,21), ylab="", space=barspace, beside=T,
    cex.names=scaling, names.arg="rand|wc", col=barcols)
title(ylab = "Time (M cycles)", mgp=c(3, 1, 0))
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(randsink),
    ylim=c(0,21), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="rand|sink", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(catwc),
    ylim=c(0,21), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="cat|wc", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(catsink),
    ylim=c(0,21), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="cat|sink", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.5,4.8,0.8))

barplot(as.matrix(catwcfs),
    ylim=c(0,21), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="fs:cat|wc", col=barcols)
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("64 KiB","128 KiB","256 KiB","512 KiB", "1024 KiB"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=gray.colors(5))

dev.off()
embed_fonts(as.character(args[1]))
