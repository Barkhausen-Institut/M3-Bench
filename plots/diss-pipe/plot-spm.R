library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.4
namescale <- 1.4

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

# convert back to time (cycles / 3)
spmtimes <- read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000000 * 3)
stddev <- scan(args[3]) / (1000000 * 3)

pdf(as.character(args[1]), width=3, height=3.2)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(5,3.5,2,1))

plot <- barplot(as.matrix(spmtimes), beside=F,
    ylim=c(0,20), space=c(0.3, 0.2, 0.2), ylab="", axes=F,
    col=colors, cex.names=namescale, las=2, mgp=c(5, 0.8, 3),
    names.arg=c("M3", "M3-rd", "M3-wr"))
axis(2, at = seq(0, 20, 5), las = 2)
error.bar(plot, colSums(spmtimes), stddev)

legend("topright", c("Total", "Idle", "OS", "Xfers"), xpd=TRUE, horiz=F, bty="n",
    inset=c(0,-0.1), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))