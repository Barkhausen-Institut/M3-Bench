library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2.4
namescale <- 2.4

# colors <- c("#2b8cbe","#a6bddb","#ece7f2")
colors <- gray.colors(3)

# convert back to time (cycles / 3)

times <- list()
for(i in 1:7) {
    times[[i]] <- read.table(as.character(args[i + 1]), header=TRUE, sep=" ") / (1000000 * 3)
}
zeros <- matrix(rep(c(NA), 6), nrow=3, ncol=3)

pdf(as.character(args[1]), width=7, height=3)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, family="Linux Biolinum")

layout(matrix(c(1,2,3,4,5,6,7), 1, 7, byrow = TRUE),
    widths=c(1.85,1,1,1,1,1,1), heights=c(1,1))

par(mar=c(12,6,4,0))

subs <- c("tar", "untar", "sha", "sort", "find", "SQLi", "LDB")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(12,0,4,0))

    barplot(as.matrix(zeros), beside=F, axes=F,
        ylim=c(0,10), space=c(0.1), ylab="",
        names.arg=rep("", 3))
    abline(h=c(seq(0,10,5)), col="gray80")

    barplot(as.matrix(times[[i]]), beside=F, axes=F, add=T,
        ylim=c(0,10), space=c(0.1), ylab="", width=c(0.98, 0.98, 0.98),
        col=colors,
        cex.names=namescale, las=3, mgp=c(4, 0.5, 0),
        names.arg=c("Lx","M3","M3x"), sub=subs[[i]])
    if(i == 1) {
        axis(2, at = seq(0, 10, 5), las = 2)
        title(ylab = "Runtime (ms)", mgp=c(3.6, 1, 0))
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("App", "Xfers", "OS"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
