library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.5
namescale <- 1.6

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(5)

ratios <- scan(as.character(args[2]))

print(ratios)

pdf(as.character(args[1]), width=5, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(4.5,6.5,1,0))

barplot(ratios, beside=T,
    ylim=c(0.99,1), ylab="Runtime (rel.)", axes=T, xpd=F,
    col=colors,
    cex.names=namescale, las=2, mgp=c(5, 1, 0),
    names.arg=c("1ms","2ms","4ms","8ms","16ms"))

dev.off()
embed_fonts(as.character(args[1]))
