args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.15

rdtimes <- read.table(as.character(args[2]), header=TRUE, sep=" ") / 1000000
wrtimes <- read.table(as.character(args[4]), header=TRUE, sep=" ") / 1000000
cptimes <- read.table(as.character(args[6]), header=TRUE, sep=" ") / 1000000
pitimes <- read.table(as.character(args[8]), header=TRUE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=5)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.4,1,1,1), heights=c(1,1))

par(mar=c(6,5,2,2))

barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,14), space=c(0.3, 0, 0), ylab="Time (M cycles)",
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Read")
box(col = 'black')

par(mar=c(6,0,2,2))

barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,14), space=c(0.3, 0, 0), axes=F,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Write")
box(col = 'black')

par(mar=c(6,0,2,2))

barplot(as.matrix(cptimes), beside=F,
    ylim=c(0,14), space=c(0.3, 0, 0), axes=F,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Copy")
box(col = 'black')

par(mar=c(6,0,2,2))

barplot(as.matrix(pitimes), beside=F,
    ylim=c(0,14), space=c(0.3, 0, 0), axes=F,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Pipe")
box(col = 'black')

legend("topright", c("Pagefaults", "Data transfers", "Remaining"), cex=1, fill=rev(gray.colors(3)))

par(mar=c(6,0,2,2))

dev.off()
