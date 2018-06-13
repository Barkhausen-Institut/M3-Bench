library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 2.2
namescale <- 2.2

colors <- c("#2b8cbe","#a6bddb","#ece7f2")
# colors <- gray.colors(3)

# convert back to time (cycles / 3)

times <- list()
for(i in 1:7) {
    times[[i]] <- read.table(as.character(args[i + 1]), header=TRUE, sep=" ") / (1000000 * 3)
}

pdf(as.character(args[1]), width=7, height=4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5,6,7), 1, 7, byrow = TRUE),
    widths=c(1.55,1,1,1,1,1,1), heights=c(1,1))

par(mar=c(8,5,4.5,1))

subs <- c("tar", "untar", "shasum", "sort", "find", "sqlite", "leveldb")
for(i in 1:length(times)) {
    if(i > 1)
        par(mar=c(8,0,4.5,1))

    barplot(as.matrix(times[[i]]), beside=F, axes=F,
        ylim=c(0,10), space=c(0.1), ylab="",
        col=colors,
        cex.names=namescale, las=3, mgp=c(5.8, 0.5, 0),
        names.arg=c("Linux","M3"), sub=subs[[i]])
    if(i == 1) {
        axis(2, at = seq(0, 10, 2), las = 2)
        title(ylab = "Time (ms)", mgp=c(3, 1, 0))
    }
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0.1,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("Application", "Data Xfers", "OS Overhead"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,-0.01), cex=namescale, fill=rev(colors))

dev.off()
embed_fonts(as.character(args[1]))
