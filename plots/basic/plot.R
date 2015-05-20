error.bar <- function(mp, means, stddevs) {
    stDevs <- matrix(stddevs, length(stddevs))
    # Plot the vertical lines of the error bars
    # The vertical bars are plotted at the midpoints
    segments(mp, means - stDevs, mp, means + stDevs, lwd=1)
    # Now plot the horizontal bounds for the error bars
    # 1. The lower bar
    segments(mp - 0.1, means - stDevs, mp + 0.1, means - stDevs, lwd=1)
    # 2. The upper bar
    segments(mp - 0.1, means + stDevs, mp + 0.1, means + stDevs, lwd=1)
}

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.15

times <- read.table(as.character(args[1]), header=TRUE, sep=" ")
stddevs <- read.table(as.character(args[2]), header=TRUE, sep=" ")

pdf(as.character(args[3]), width=7, height=5)

layout(matrix(c(1,2,3), 1, 3, byrow = TRUE),
    widths=c(1,1.3,1), heights=c(1,1))

par(mar=c(3,5,3,3))

sys <- times[1,]
systimes <- cbind(rbind(sys$M3,0,0),rbind(0,sys$Linux,sys$LinuxCM))
barx <- barplot(systimes, col=gray.colors(3), ylab="Time (cycles)",
    space=0, ylim=c(0,1000),
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling, cex.names=namescale,
    names.arg=c("             Syscall", ""))

error.bar(barx, as.vector(rbind(cbind(sys$M3[[1]]),cbind(sys$Linux+sys$LinuxCM))), stddevs$Syscall)
box(col = 'black')

par(mar=c(3,2,3,2))

clone <- times[-1,][-5,][-4,]
clonetimes <- cbind(rbind(clone$M3,0,0),rbind(0,clone$Linux,clone$LinuxCM))[,c(1,4,5,6)]
barx <- barplot(clonetimes, col=gray.colors(3), axes = FALSE,
    space=c(0, 0), ylim=c(0,200000),
    cex.names=namescale,
    names.arg=c("M3-run", "pthrd", "clone", "fork"))

error.bar(barx, as.vector(rbind(cbind(clone$M3[[1]]),cbind(clone$Linux+clone$LinuxCM))), stddevs$Thread)
axis(side = 2, labels = TRUE, cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)
box(col = 'black')

par(mar=c(3,2,3,1))

exec <- times[-1,][-1,][-1,][-1,]
exectimes <- cbind(rbind(exec$M3,0,0),rbind(0,exec$Linux,exec$LinuxCM))[,c(1,3,4)]
barx <- barplot(exectimes, col=gray.colors(3), axes = FALSE,
    space=c(0, 0), ylim=c(0,700000),
    cex.names=namescale,
    names.arg=c("M3-exec", "exec", "vfork"))

legend("topright", c("M3", "Linux", "Cache-misses"), cex=1, fill=gray.colors(3))
error.bar(barx, as.vector(rbind(cbind(exec$M3[[1]]),cbind(exec$Linux+exec$LinuxCM))), stddevs$Exec)
axis(side = 2, labels = TRUE, cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)
box(col = 'black')

dev.off()
