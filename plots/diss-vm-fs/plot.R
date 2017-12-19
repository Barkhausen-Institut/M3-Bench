library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 2

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(2)

# convert back to time (cycles / 3)
rdtimes  <- read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000000 * 3)
rdstddev <- scan(args[3]) / (1000000 * 3)
wrtimes  <- read.table(as.character(args[4]), header=TRUE, sep=" ") / (1000000 * 3)
wrstddev <- scan(args[5]) / (1000000 * 3)
cptimes  <- read.table(as.character(args[6]), header=TRUE, sep=" ") / (1000000 * 3)
cpstddev <- scan(args[7]) / (1000000 * 3)

pdf(as.character(args[1]), width=5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3), 1, 3, byrow = TRUE),
    widths=c(1.5,1,1), heights=c(1,1))

par(mar=c(9.5,6,4,1))

plot <- barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,12), space=c(0.3, 0.2, 0.2), ylab="", axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(7, 0.5, 0),
    names.arg=c("M3-a","M3-b","M3-c"), sub="Read")
axis(2, at = seq(0, 12, 3), las = 2)
title(ylab = "Time (ms)", mgp=c(4, 1, 0))
error.bar(plot, colSums(rdtimes), rdstddev)

par(mar=c(9.5,0,4,1))

plot <- barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,12), space=c(0.3, 0.2, 0.2), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(7, 0.5, 0),
    names.arg=c("M3-a","M3-b","M3-c"), sub="Write")
error.bar(plot, colSums(wrtimes), wrstddev)

par(mar=c(9.5,0,4,1))

plot <- barplot(as.matrix(cptimes), beside=F,
    ylim=c(0,12), space=c(0.3, 0.2, 0.2), axes=F,
    col=colors,
    cex.names=namescale, las=3, mgp=c(7, 0.5, 0),
    names.arg=c("M3-a","M3-b","M3-c"), sub="Copy")
error.bar(plot, colSums(cptimes), cpstddev)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("OS", "Xfers"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.0), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
