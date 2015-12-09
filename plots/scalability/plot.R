args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.5
namescale <- 1.3

pipewc_times <- read.table(as.character(args[2]), header=FALSE, sep=" ")
pipewc_times <- pipewc_times / pipewc_times$V2
tar_times <- read.table(as.character(args[3]), header=FALSE, sep=" ")
tar_times <- tar_times / tar_times$V1
untar_times <- read.table(as.character(args[4]), header=FALSE, sep=" ")
untar_times <- untar_times / untar_times$V1
find_times <- read.table(as.character(args[5]), header=FALSE, sep=" ")
find_times <- find_times / find_times$V1
sqlite_times <- read.table(as.character(args[6]), header=FALSE, sep=" ")
sqlite_times <- sqlite_times / sqlite_times$V1

pdf(as.character(args[1]), width=7, height=4)

par(mar=c(5.1,5.1,3.1,2.1))

# Graph cars using blue points overlayed by a line
plot(as.double(pipewc_times), ylim=c(0.75,2.5), type="o", pch=0, lty=1,
     cex.lab=namescale, axes=FALSE, ylab="Time (normalized)", xlab="# of Application PEs")
lines(as.double(tar_times), ylim=c(0.75,2.5), type="o", pch=1, lty=2)
lines(as.double(untar_times), ylim=c(0.75,2.5), type="o", pch=2, lty=3)
lines(as.double(find_times), ylim=c(0.75,2.5), type="o", pch=3, lty=4)
lines(as.double(sqlite_times), ylim=c(0.75,2.5), type="o", pch=4, lty=5)

axis(side = 1, at = 1:5, lab = c("1","2","4","8","16"),
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)
axis(side = 2, at = seq(1, 2.5, by = 0.5), labels = TRUE,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

linetype <- c(1:5)
plotchar <- seq(0, 5, 1)
legend("topleft", c("cat+tr", "tar", "untar", "find", "sqlite"), cex=namescale, pch=plotchar, lty=linetype)

box(col = 'black')

dev.off()
