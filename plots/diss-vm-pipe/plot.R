library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 2

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

# convert back to time (cycles / 3)
tottimes  <- read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000000 * 3)
totstddev <- scan(args[3]) / (1000000 * 3)
rdtimes  <- read.table(as.character(args[4]), header=TRUE, sep=" ") / (1000000 * 3)
rdstddev <- scan(args[5]) / (1000000 * 3)
wrtimes  <- read.table(as.character(args[6]), header=TRUE, sep=" ") / (1000000 * 3)
wrstddev <- scan(args[7]) / (1000000 * 3)

pdf(as.character(args[1]), width=5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3), 1, 3, byrow = TRUE),
    widths=c(1.5,1,1), heights=c(1,1))

par(mar=c(9.5,6,4,1))

plot <- barplot(as.matrix(tottimes), beside=F,
    ylim=c(0,10), space=c(0.3, 0.2, 0.2), ylab="", axes=F,
    col=rev(colors),
    cex.names=namescale, las=3, mgp=c(7, 0.5, 0),
    names.arg=c("M3-A","M3-B","M3-C"), sub="Total")
axis(2, at = seq(0, 10, 3), las = 2)
title(ylab = "Time (ms)", mgp=c(4, 1, 0))
error.bar(plot, colSums(tottimes), totstddev)

par(mar=c(9.5,0,4,1))

plot <- barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,10), space=c(0.3, 0.2, 0.2), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(7, 0.5, 0),
    names.arg=c("M3-A","M3-B","M3-C"), sub="Reader")
error.bar(plot, colSums(rdtimes), rdstddev)

par(mar=c(9.5,0,4,1))

plot <- barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,10), space=c(0.3, 0.2, 0.2), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(7, 0.5, 0),
    names.arg=c("M3-A","M3-B","M3-C"), sub="Writer")
error.bar(plot, colSums(wrtimes), wrstddev)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Total", "Idle", "OS", "Xfers"), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
