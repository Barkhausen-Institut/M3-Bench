library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2
namescale <- 2
colors <- brewer.pal(n = 3, name = "Pastel1")[1:2]

times   <- list()
stddevs <- list()
for(i in 1:3) {
    # convert back to time (cycles / 3)
    times[[i]]   <- read.table(as.character(args[i * 2]), header=TRUE, sep=" ") / (1000000 * 3)
    stddevs[[i]] <- scan(args[i * 2 + 1]) / (1000000 * 3)
}
zeros2 <- matrix(rep(c(NA), 2 * 2), nrow=2, ncol=2)
zeros3 <- matrix(rep(c(NA), 3 * 2), nrow=2, ncol=3)

pdf(as.character(args[1]), width=5, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

layout(matrix(c(1,2,3), 1, 3, byrow = TRUE),
    widths=c(1.15,1,1), heights=c(1,1))

par(mar=c(9.5,6,4,0))

subs <- c("Read   ", "Write   ", "Copy   ")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(9.5,0,4,0))

    if(i == 1)
        names <- c("Linux", "M³")
    else if(i == 2)
        names <- c("Linux", "M³", "M³-zero")
    else
        names <- c("Linux", "M³", "Lx-send")

    barplot(as.matrix(if(i == 1) zeros2 else zeros3), beside=F, ylim=c(0,30), axes=F,
        space=rep(0.15, length(names)), names.arg=rep("", length(names)))
    abline(h=c(seq(0,30,5)), col="gray80")

    plot <- barplot(as.matrix(times[[i]]), beside=F, add=T,
        ylim=c(0,30), space=rep(0.15, length(names)), axes=F, width=rep(c(0.9), length(names)),
        col=colors,
        cex.names=namescale, las=3, mgp=c(7, 0.5, 0),
        names.arg=names, sub=subs[[i]])
    if(i == 1) {
        axis(2, at = seq(0, 30, 5), las = 2)
        title(ylab = "Time (ms)", mgp=c(4, 1, 0))
    }
    error.bar(plot, colSums(times[[i]]), stddevs[[i]])
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("OS Overhead", "Data Transfers"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
