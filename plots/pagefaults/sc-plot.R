library(extrafont)
source("tools/helper.R")

scaling <- 1.1
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=6, height=1.8)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

syscv  = rev(scan(args[2]))
syscd  = rev(scan(args[3]))

par(mar=c(4.5,1,1.5,1))

plot = barplot(
    as.matrix(syscv),
    beside=T,
    horiz=TRUE,
    xlab = "Duration (Cycles)",
    xlim = c(0, 1100),
    space = c(0.3),
    col=rev(gray.colors(4)),
    mgp = c(2.3, 1, 0)
)
error.bar(plot, syscv, syscd, horizontal=T)

legend("top", c("Linux", "M3-A", "M3-C", "M3-C*"), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,-0.55), cex=scaling, fill=gray.colors(4))

dev.off()
embed_fonts(as.character(args[1]))
