library(extrafont)
library(RColorBrewer)
source("tools/helper.R")

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.5
namescale <- 1.5
colors <- brewer.pal(n = 3, name = "Pastel1")[1:2]

times   <- list()
stddevs <- list()
for(i in 1:5) {
    times[[i]]   <- read.table(as.character(args[i * 2]), header=TRUE, sep=" ") / 1000000
    stddevs[[i]] <- scan(args[i * 2 + 1]) / 1000000
}
zeros3 <- matrix(rep(c(NA), 3 * 2), nrow=2, ncol=3)

pdf(as.character(args[1]), width=5, height=2.2)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5), 1, 5, byrow = TRUE),
    widths=c(1.7,1,1,1,1.7), heights=c(1,1))

par(mar=c(6,4,1.5,0))

subs <- c("Read", "Insert", "Update", "Mixed", "Scan")
for(i in 1:length(times)) {
    if(i == 5)
        par(mar=c(6,3,1.5,0))
    else if(i > 1)
        par(mar=c(6,0,1.5,0))

    names <- c("UCS²i", "UCS²s", "Linux")

    # XXX: collides with sub
    # barplot(as.matrix(zeros3), beside=F, ylim=c(0,50), axes=F,
    #     space=rep(0.15, length(names)), names.arg=rep("", length(names)), sub=subs[[i]])
    # abline(h=c(seq(0,50,10)), col="gray80", lwd=2)

    plot <- barplot(as.matrix(times[[i]]), beside=F, add=F,
        ylim=if(i == 5) c(0,30) else c(0,5),
        space=rep(0.15, length(names)), axes=F, width=rep(c(0.9), length(names)),
        col=colors, sub=subs[[i]],
        cex.names=namescale, las=3, mgp=c(3.8, .5, 0),
        names.arg=names)
    if(i == 1) {
        axis(2, at = seq(0,5,1), las = 2)
        title(ylab = "Time (s)", mgp=c(2.3, 1, 0))
    }
    else if(i == 5) {
        axis(2, at = seq(0,30,10), las = 2)
    }
    error.bar(plot, colSums(times[[i]]), stddevs[[i]])
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("User", "System"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=namescale, fill=colors)

dev.off()
embed_fonts(as.character(args[1]))
