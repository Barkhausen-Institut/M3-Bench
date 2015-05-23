args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.15

rdtimes <- read.table(as.character(args[2]), header=TRUE, sep=" ")
cktimes <- read.table(as.character(args[4]), header=TRUE, sep=" ")
wrtimes <- read.table(as.character(args[6]), header=TRUE, sep=" ")
cptimes <- read.table(as.character(args[8]), header=TRUE, sep=" ")

pdf(as.character(args[1]), width=7, height=5)

layout(matrix(c(1,2,3,4), 1, 4, byrow = TRUE),
    widths=c(1.4,1,1,1), heights=c(1,1))

par(mar=c(5,5,3,2))

barplot(as.matrix(rdtimes), beside=F,
    ylim=c(0,14000000), space=c(0.3, 0, 0), ylab="Time (cycles)",
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Read")
box(col = 'black')

legend("topleft", c("Remaining", "Data transfers", "Pagefaults"), cex=1, fill=gray.colors(3))

par(mar=c(5,0,3,2))

barplot(as.matrix(wrtimes), beside=F,
    ylim=c(0,14000000), space=c(0.3, 0, 0), axes=F,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Write")
box(col = 'black')

par(mar=c(5,0,3,2))

barplot(as.matrix(cktimes), beside=F,
    ylim=c(0,14000000), space=c(0.3, 0, 0), axes=F,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Checksum")
box(col = 'black')

par(mar=c(5,0,3,2))

barplot(as.matrix(cptimes), beside=F,
    ylim=c(0,14000000), space=c(0.3, 0, 0), axes=F,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("M3","Lx","Lx-$"), sub="Copy")
box(col = 'black')

par(mar=c(5,0,3,2))

dev.off()
