library(extrafont)
source("tools/helper.R")

scaling <- 0.9
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=5, height=1.4)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

# convert back to time (cycles / 3)
# show k cycles per page (64 pages)
anon1v = scan(args[2]) / (64 * 1000 * 3)
anon1d = scan(args[3]) / (64 * 1000 * 3)
file1v = scan(args[4]) / (64 * 1000 * 3)
file1d = scan(args[5]) / (64 * 1000 * 3)
anon4v = scan(args[6]) / (64 * 1000 * 3)
anon4d = scan(args[7]) / (64 * 1000 * 3)
file4v = scan(args[8]) / (64 * 1000 * 3)
file4d = scan(args[9]) / (64 * 1000 * 3)

layout(matrix(c(1,2), 1, 2, byrow = TRUE),
    widths=c(1.9,1), heights=c(1,1))

par(mar=c(2.5,4.5,1,0))

plot = barplot(
    cbind(anon1v[-2], file1v[-2]),
    space = c(0.1, 0.3),
    beside=T,
    names=c("Anon 1P", "File 1P"),
    ylim = c(0, 10),
    ylab = "Time (ms)",
    axes=F,
    col=gray.colors(3),
    mgp = c(2.3, 0.5, 0)
)
axis(2, at = seq(0, 10, 5), las = 2)
error.bar(plot,
    as.double(cbind(anon1v[-2],file1v[-2])),
    as.double(cbind(anon1d[-2],file1d[-2])))

par(mar=c(2.5,0.2,1,0))

plot = barplot(
    cbind(anon4v[c(-1,-2)], file4v[c(-1,-2)]),
    space = c(0.1, 0.3),
    beside=T,
    names=c("Anon 4P", "File 4P"),
    ylim = c(0, 10),
    axes=F,
    col=gray.colors(3)[-1],
    mgp = c(2.3, 0.5, 0)
)
error.bar(plot,
    as.double(cbind(anon4v[c(-1,-2)], file4v[c(-1,-2)])),
    as.double(cbind(anon4d[c(-1,-2)], file4d[c(-1,-2)])))

legend("topright", c("Linux", "M3-C", "M3-C*"), xpd=TRUE, horiz=F, bty="n",
    inset=c(0,-0.3), cex=scaling, fill=gray.colors(3))

dev.off()
embed_fonts(as.character(args[1]))
