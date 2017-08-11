library(extrafont)
source("tools/helper.R")

scaling <- 1.2
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=6, height=3.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

# show k cycles per page (64 pages)
anon1v = scan(args[2]) / (64 * 1000)
anon1d = scan(args[3]) / (64 * 1000)
file1v = scan(args[4]) / (64 * 1000)
file1d = scan(args[5]) / (64 * 1000)
anon4v = scan(args[6]) / (64 * 1000)
anon4d = scan(args[7]) / (64 * 1000)
file4v = scan(args[8]) / (64 * 1000)
file4d = scan(args[9]) / (64 * 1000)

layout(matrix(c(1,2), 1, 2, byrow = TRUE),
    widths=c(1.6,1), heights=c(1,1))

par(mar=c(2.5,4.5,1,0))

plot = barplot(
    cbind(anon1v[-2], file1v[-2]),
    space = c(0.1, 1.2),
    beside=T,
    names=c("Anon 1P", "File 1P"),
    ylim = c(0, 30),
    ylab = "Duration (K Cycles)",
    col=gray.colors(3)
)
error.bar(plot,
    as.double(cbind(anon1v[-2],file1v[-2])),
    as.double(cbind(anon1d[-2],file1d[-2])))

par(mar=c(2.5,1,1,0))

plot = barplot(
    cbind(anon4v[c(-1,-2)], file4v[c(-1,-2)]),
    space = c(0.1, 1.2),
    beside=T,
    names=c("Anon 4P", "File 4P"),
    ylim = c(0, 30),
    axes=F,
    col=gray.colors(3)[-1]
)
error.bar(plot,
    as.double(cbind(anon4v[c(-1,-2)], file4v[c(-1,-2)])),
    as.double(cbind(anon4d[c(-1,-2)], file4d[c(-1,-2)])))

legend("topright", c("Linux", "M3c-C", "M3c-C*"), xpd=TRUE, horiz=F, bty="n",
    inset=c(0,-0.06), cex=scaling, fill=gray.colors(3))

dev.off()
embed_fonts(as.character(args[1]))
