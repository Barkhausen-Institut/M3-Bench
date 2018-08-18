library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.5
namescale <- 1.6

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(4)

times  <- read.table(as.character(args[2]), header=F, sep=" ") / 1000
stddev <- read.table(as.character(args[3]), header=F, sep=" ") / 1000

pdf(as.character(args[1]), width=10, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

par(mar=c(5,10.5,3,1))

plot <- barplot(t(times), beside=F, horiz=T,
    xlim=c(0,11), xlab="Time (µs)", axes=F,
    col=colors,
    cex.names=namescale, las=1, mgp=c(3, 1, 0),
    names.arg=c("M³-C (local)", "M³-C (rem-sh)", "M³-C (rem-ex)", "M³-B (rem-sh)", "M³-B (rem-ex)",
                "M³-A (rem-sh)", "M³-A (rem-ex)", "NOVA (remote)", "NOVA (local)"))
error.bar(plot, colSums(t(times)), t(stddev), horizontal=T)
axis(1, at = seq(0, 11, 1), las = 1)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Wake", "CtxSw", "Fwd", "Comm"), xpd=TRUE, horiz=T, bty="n",
    inset=c(0,0), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
