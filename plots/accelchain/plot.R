library(extrafont)
source("tools/helper.R")

scaling <- 1.6
args <- commandArgs(trailingOnly = TRUE)

# convert back to time (cycles / 3)
v1 = read.table(as.character(args[2]), header=F, sep=" ") / (1000000 * 3)
v2 = read.table(as.character(args[3]), header=F, sep=" ") / (1000000 * 3)
v3 = read.table(as.character(args[4]), header=F, sep=" ") / (1000000 * 3)
v4 = read.table(as.character(args[5]), header=F, sep=" ") / (1000000 * 3)
v5 = read.table(as.character(args[6]), header=F, sep=" ") / (1000000 * 3)
v6 = read.table(as.character(args[7]), header=F, sep=" ") / (1000000 * 3)
# dev = read.table(as.character(args[3]), header=F, sep=" ") / 1000000

pdf(as.character(args[1]), width=8, height=1.4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5,6), 1, 6, byrow = TRUE),
    widths=c(1.6,1,1,1,1,1), heights=c(1,1))

par(mar=c(2.2,5,3.2,0))

plot = barplot(
    as.matrix(v1),
    beside=T,
    ylab="Time (ms)",
    ylim=c(0, 25),
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names="1 Accel.",
    axes=F,
    col=rep(gray.colors(6), each=3)
)
axis(2, at = seq(0, 25, 5), las = 2)
# error.bar(plot, vals, dev)

par(mar=c(2.2,0,3.2,0))

plot = barplot(
    as.matrix(v2),
    beside=T,
    axes=F,
    ylim=c(0, 25),
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names="2 Accel.",
    col=rep(gray.colors(6), each=3)
)

par(mar=c(2.2,0,3.2,0))

plot = barplot(
    as.matrix(v3),
    beside=T,
    axes=F,
    ylim=c(0, 25),
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names="3 Accel.",
    col=rep(gray.colors(6), each=3)
)

par(mar=c(2.2,0,3.2,0))

plot = barplot(
    as.matrix(v4),
    beside=T,
    axes=F,
    ylim=c(0, 25),
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names="4 Accel.",
    col=rep(gray.colors(6), each=3)
)

par(mar=c(2.2,0,3.2,0))

plot = barplot(
    as.matrix(v5),
    beside=T,
    axes=F,
    ylim=c(0, 25),
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names="5 Accel.",
    col=rep(gray.colors(6), each=3)
)

par(mar=c(2.2,0,3.2,0))

plot = barplot(
    as.matrix(v6),
    beside=T,
    axes=F,
    ylim=c(0, 25),
    space=c(0.3, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0, 0.5, 0, 0),
    names="6 Accel.",
    col=rep(gray.colors(6), each=3)
)

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
legend("top", c("2K", "4K", "8K", "16K", "32K", "64K"), xpd=TRUE, horiz=TRUE, bty="n",
    inset=c(0,0), cex=scaling, fill=gray.colors(6))

dev.off()
embed_fonts(as.character(args[1]))
