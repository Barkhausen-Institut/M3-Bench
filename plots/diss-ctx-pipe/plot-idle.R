library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.1
namescale <- 1.1
colors <- brewer.pal(n = 4, name = "Pastel1")

# convert back to time (cycles / 3)
times <- list()
for(i in 1:4) {
    times[[i]]   <- read.table(as.character(args[i + 1]), header=F, sep=" ")
}
zeros <- matrix(rep(c(NA), 4 * 2), nrow=4, ncol=2)

pdf(as.character(args[1]), width=5, height=2)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Ubuntu")

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.8,1,1.1), heights=c(1,1))

par(mar=c(5,5,3.2,0))

names <- list("rand|wc  ", "rand|sink  ", "cat|wc  ", "cat|sink  ")
for(i in 1:length(names)) {
    if(i > 1)
        par(mar=c(5,0,3.2,0))

    barplot(t(as.matrix(zeros)), beside=T, ylim=c(0,1), axes=F,
        space=rep(c(0.5, 0, 0, 0), 4), names.arg=rep("", 4))
    abline(h=c(seq(0,1,.2)), col="gray80", lwd=1.3)

    plot <- barplot(t(as.matrix(times[[i]])), beside=T, add=T, width=rep(c(0.95), 4),
        ylim=c(0,1),
        space=rep(c(0.5, 0, 0, 0), 4),
        axes=F,
        col=colors,
        cex.names=namescale, las=3, mgp=c(2.5, 0.5, 0),
        names.arg=c("512","1024","2048","4096"), sub=names[[i]])
    if(i == 1) {
        axis(2, at = seq(0, 1, .20), las = 2)
        title(ylab = "Utilization", mgp=c(2.8, 1, 0))
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,1.2,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("M³ (5)", "M³-srv (3)", "M³-all (2)", "M³-all (1)"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
