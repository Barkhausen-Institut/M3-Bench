library(extrafont)
source("tools/helper.R")

scaling <- 1.6
args <- commandArgs(trailingOnly = TRUE)

pdf(as.character(args[1]), width=6, height=4.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

# show time per page (64 pages)
anon1v = scan(args[2]) / 64
anon1d = scan(args[3]) / 64
file1v = scan(args[4]) / 64
file1d = scan(args[5]) / 64
anon4v = scan(args[6]) / 64
anon4d = scan(args[7]) / 64
file4v = scan(args[8]) / 64
file4d = scan(args[9]) / 64
syscv  = scan(args[10])
syscd  = scan(args[11])

layout(matrix(c(1,2,3), 1, 3, byrow = TRUE),
    widths=c(1.05,1.7,1.2), heights=c(1,1))

par(mar=c(2.5,5,2,0))

plot = barplot(
    as.matrix(syscv),
    beside=T,
    names=c("Syscall"),
    ylab = "Time (Cycles)",
    ylim = c(0, 1100),
    col=gray.colors(4)
)
error.bar(plot, syscv, syscd)

par(mar=c(2.5,3,2,0))

plot = barplot(
    cbind(anon1v[-2], file1v[-2]),
    beside=T,
    names=c("Anon 1P", "File 1P"),
    ylim = c(0, 30000),
    col=gray.colors(4)[-2]
)
error.bar(plot,
    as.double(cbind(anon1v[-2],file1v[-2])),
    as.double(cbind(anon1d[-2],file1d[-2])))

par(mar=c(2.5,0.5,2,0))

plot = barplot(
    cbind(anon4v[c(-1,-2)], file4v[c(-1,-2)]),
    beside=T,
    names=c("Anon 4P", "File 4P"),
    ylim = c(0, 30000),
    axes=F,
    col=gray.colors(4)[c(-1,-2)]
)
error.bar(plot,
    as.double(cbind(anon4v[c(-1,-2)], file4v[c(-1,-2)])),
    as.double(cbind(anon4d[c(-1,-2)], file4d[c(-1,-2)])))

legend("topright", c("Linux", "M3c-A", "M3c-C", "M3c-C*"), xpd=TRUE, horiz=F, bty="n",
    inset=c(0,0.01), cex=scaling, fill=gray.colors(4))

dev.off()
embed_fonts(as.character(args[1]))
