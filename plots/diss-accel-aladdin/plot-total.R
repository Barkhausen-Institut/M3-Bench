library(extrafont)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.8
namescale <- 1.8

# colors <- c("#FF8B8B","#CCCCCC","#AFDDFF")
colors <- gray.colors(6)

# convert back to time (cycles / 3)
times <- list()
for(i in 1:4) {
    times[[i]] <- scan(args[i + 1]) / (1000000 * 3)
}
zeros <- matrix(rep(c(NA), 6 * 1), nrow=6, ncol=1)

pdf(as.character(args[1]), width=4, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.86,1,1,1), heights=c(1,1))

par(mar=c(9.5,5.5,4,0))

subs <- c("Stencil ", "MD ", "FFT ", "SPMV ")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(9.5,0,4,0))

    barplot(t(as.matrix(zeros)), beside=F, ylim=c(0,1.2), axes=F,
        space=c(0.3, 0.2), names.arg=rep("", 6))
    abline(h=c(seq(0,1.2,0.3)), col="gray80")

    plot <- barplot(times[[i]], beside=F, add=T, width=rep(c(0.9), 6),
        ylim=c(0,1.2), space=c(0.3, 0.2), axes=F,
        col=colors,
        cex.names=namescale, las=3, mgp=c(0, 0.5, 0),
        sub=subs[[i]])
    if(i == 1) {
        axis(2, at = seq(0, 1.2, 0.3), las = 2)
        title(ylab = "Time (ms)", mgp=c(3.6, 1, 0))
    }
}

dev.off()
embed_fonts(as.character(args[1]))
