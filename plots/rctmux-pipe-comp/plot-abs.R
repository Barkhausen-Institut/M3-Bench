library(extrafont)
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.5
namescale <- 1.5

read100   <- as.data.table(read.table(as.character(args[2]), header=TRUE, sep=" ")) / 1000000
read500   <- as.data.table(read.table(as.character(args[3]), header=TRUE, sep=" ")) / 1000000
read750   <- as.data.table(read.table(as.character(args[4]), header=TRUE, sep=" ")) / 1000000
read1000  <- as.data.table(read.table(as.character(args[5]), header=TRUE, sep=" ")) / 1000000
write100  <- as.data.table(read.table(as.character(args[6]), header=TRUE, sep=" ")) / 1000000
write500  <- as.data.table(read.table(as.character(args[7]), header=TRUE, sep=" ")) / 1000000
write750  <- as.data.table(read.table(as.character(args[8]), header=TRUE, sep=" ")) / 1000000

pdf(as.character(args[1]), width=7.5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5,6,7), 1, 7, byrow = TRUE),
    widths=c(1.7,1,1,1,1,1,1), heights=c(1,1))

par(mar=c(2.8,5.2,3,0.2))

barspace = c(0.1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0)
cols = c("#FF8000", "#00B000", "#0000B0", "#B00000", "#00B0B0")
barcols = c(cols[1], cols[1], cols[1],
            cols[2], cols[2], cols[2],
            cols[3], cols[3], cols[3],
            cols[4], cols[4], cols[4],
            cols[5], cols[5], cols[5])

barplot(as.matrix(read100),
    ylim=c(0,150), ylab="", space=barspace, beside=T,
    cex.names=scaling, names.arg="100/10", col=barcols)
title(ylab = "Time (M cycles)", mgp=c(3, 1, 0))
box(col = 'black')

par(mar=c(2.8,0.2,3,0.2))

barplot(as.matrix(write100),
    ylim=c(0,150), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="10/100", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.2,3,0.2))

barplot(as.matrix(read500),
    ylim=c(0,150), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="100/50", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.2,3,0.2))

barplot(as.matrix(write500),
    ylim=c(0,150), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="50/100", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.2,3,0.2))

barplot(as.matrix(read750),
    ylim=c(0,150), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="100/75", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.2,3,0.2))

barplot(as.matrix(write750),
    ylim=c(0,150), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="75/100", col=barcols)
box(col = 'black')

par(mar=c(2.8,0.2,3,0.2))

barplot(as.matrix(read1000),
    ylim=c(0,150), axes=F, space=barspace, beside=T,
    cex.names=scaling, names.arg="100/100", col=barcols)
box(col = 'black')

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("32k", "64k", "128k", "256k", "512k"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=cols)

dev.off()
embed_fonts(as.character(args[1]))
