library(extrafont)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.6
namescale <- 1.6
colors <- brewer.pal(n = 3, name = "Pastel1")

# convert back to time (cycles / 3)

times <- list()
for(i in 1:7) {
    times[[i]] <- read.table(as.character(args[i + 1]), header=TRUE, sep=" ") / (1000000 * 3)
}
zeros <- matrix(rep(c(NA), 6), nrow=3, ncol=2)

pdf(as.character(args[1]), width=7, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5,6,7), 1, 7, byrow = TRUE),
    widths=c(1.7,1,1,1,1,1,1), heights=c(1,1))

par(mar=c(8,5,3.5,0))

subs <- c("tar  ", "untar  ", "shasum  ", "sort  ", "find  ", "SQLite  ", "LevelDB  ")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(8,0,3.5,0))

    barplot(as.matrix(zeros), beside=F, axes=F,
        ylim=c(0,10), space=c(0.1), ylab="",
        names.arg=rep("", 2), sub=subs[[i]])
    abline(h=c(seq(0,10,2)), col="gray80", lwd=2)

    barplot(as.matrix(times[[i]]), beside=F, axes=F, add=T,
        ylim=c(0,10), space=c(0.1), ylab="", width=c(0.9, 0.9),
        col=colors,
        cex.names=namescale, las=3, mgp=c(2.5, 0.5, 0),
        names.arg=c("Lx","M³"), sub=subs[[i]])
    if(i == 1) {
        axis(2, at = seq(0, 10, 2), las = 2)
        title(ylab = "Time (ms)", mgp=c(3, 1, 0))
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("App", "Xfers", "OS"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
