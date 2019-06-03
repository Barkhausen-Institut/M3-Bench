library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 2

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(1)

times  <- read.table(as.character(args[2]), header=F, sep=" ") / 1000
stddev <- read.table(as.character(args[3]), header=F, sep=" ") / 1000

pdf(as.character(args[1]), width=8, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Linux Biolinum")

par(mar=c(4.5,11.5,0,1))

plot <- barplot(t(times), beside=F, horiz=T,
    xlim=c(0,10), xlab="Time (µs)", axes=F,
    col=colors,
    cex.names=namescale, las=1, mgp=c(3, 1, 0),
    names.arg=c("x86-64 (local)", "x86-64 (fwd)", "x86-64 (fast)", "RP-accel (fwd)", "RP-accel (fast)",
                "SP-accel (fwd)", "SP-accel (fast)"))
error.bar(plot, colSums(t(times)), t(stddev), horizontal=T)
axis(1, at = seq(0, 10, 1), las = 1)

dev.off()
embed_fonts(as.character(args[1]))
