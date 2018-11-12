library(extrafont)
library(plotrix)
library(RColorBrewer)
source("tools/helper.R")
options(warn=1)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2.2
namescale <- 2.2
colors <- brewer.pal(n = 4, name = "Pastel1")

# convert back to time (cycles / 3)
times  <- t(read.table(as.character(args[2]), header=TRUE, sep=" ") / (1000000 * 3))
stddev <- t(read.table(as.character(args[3]), header=FALSE, sep=" ") / (1000000 * 3))
zeros  <- matrix(rep(c(NA), 4 * 1), nrow=1, ncol=4)

# cap values at 0.2
ctimes <- replace(times, T, pmin(0.22, times))

pdf(as.character(args[1]), width=10, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

layout(matrix(c(1,2,3,4,5), 1, 5, byrow = TRUE),
    widths=c(1.45,1,1,1,1), heights=c(1,1))

par(mar=c(8,6,2,0))

subs <- c("Linux  ", "M³-A  ", "M³-B  ", "M³-C  ", "M³-C*  ")
for(i in 1:length(subs)) {
    if(i > 1)
        par(mar=c(8,0,2,0))

    barplot(as.matrix(zeros), beside=T, ylim=c(0,0.25), axes=F, space=rep(c(0.1), 4))
    abline(h=c(seq(0,0.2,0.05)), col="gray80")

    plot <- barplot(as.matrix(ctimes[i,]), beside=T, add=T,
        ylim=c(0,0.25), space=rep(c(0.1), 4), ylab="", axes=F, width=rep(c(0.95), 4),
        col=colors,
        cex.names=namescale, las=3, mgp=c(5.5, 0.5, 0),
        names.arg=c("1 B", "2 MiB", "4 MiB", "8 MiB"), sub=subs[[i]])
    if(i == 1) {
        axis(2, at = seq(0, 0.22, 0.1), las = 2)
        title(ylab = "Time (ms)", mgp=c(4, 1, 0))
    }
    error.bar(plot, ctimes[i,], stddev[i,])

    if(times[i,2] > ctimes[i,2]) {
        bar.break(plot, 2, 0.2, 0.004, 0.001)
        text(plot[2], 0.235, round(times[i,2],1), cex=2)
    }
    if(times[i,3] > ctimes[i,3]) {
        bar.break(plot, 3, 0.2, 0.004, 0.001)
        text(plot[3], 0.235, round(times[i,3],1), cex=2)
    }
    if(times[i,4] > ctimes[i,4]) {
        bar.break(plot, 4, 0.2, 0.004, 0.001)
        text(plot[4], 0.235, round(times[i,4],1), cex=2)
    }
}

dev.off()
embed_fonts(as.character(args[1]))
