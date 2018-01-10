library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.7
namescale <- 1.7

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

# convert back to time (cycles / 3)
anon1times  <- read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000 * 3)
anon1stddev <- scan(args[3]) / (1000 * 3)
file1times  <- read.table(as.character(args[4]), header=TRUE, sep=" ") / (1000 * 3)
file1stddev <- scan(args[5]) / (1000 * 3)
anon4times  <- read.table(as.character(args[6]), header=TRUE, sep=" ") / (1000 * 3)
anon4stddev <- scan(args[7]) / (1000 * 3)
file4times  <- read.table(as.character(args[8]), header=TRUE, sep=" ") / (1000 * 3)
file4stddev <- scan(args[9]) / (1000 * 3)

anon4times  <- anon4times[c(-1)]
anon4stddev <- anon4stddev[c(-1)]
file4times  <- file4times[c(-1)]
file4stddev <- file4stddev[c(-1)]

pdf(as.character(args[1]), width=6, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.5,1,0.8,0.8), heights=c(1,1))

par(mar=c(7,6,4,0.5))

plot <- barplot(as.matrix(anon1times), beside=F,
    ylim=c(0,11), space=c(0.3, 0.2, 0.2, 0.2), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("Linux","M3-B","M3-C","M3-C*"), sub="Anon 1P")
axis(2, at = seq(0, 11, 2), las = 2)
title(ylab = "Time (µs)", mgp=c(4, 1, 0))
error.bar(plot, colSums(anon1times), anon1stddev)

par(mar=c(7,0,4,0.5))

plot <- barplot(as.matrix(file1times), beside=F,
    ylim=c(0,11), space=c(0.3, 0.2, 0.2, 0.2), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("Linux","M3-B","M3-C","M3-C*"), sub="File 1P")
error.bar(plot, colSums(file1times), file1stddev)

par(mar=c(7,0,4,0.5))

plot <- barplot(as.matrix(anon4times), beside=F,
    ylim=c(0,11), space=c(0.3, 0.2, 0.2), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("M3-B","M3-C","M3-C*"), sub="Anon 4P")
error.bar(plot, colSums(anon4times), anon4stddev)

par(mar=c(7,0,4,0.5))

plot <- barplot(as.matrix(file4times), beside=F,
    ylim=c(0,11), space=c(0.3, 0.2, 0.2), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(4.5, 0.5, 0),
    names.arg=c("M3-B","M3-C","M3-C*"), sub="File 4P")
error.bar(plot, colSums(file4times), file4stddev)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Kernel", "m3fs", "Pager", "VMA/DTU"), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
