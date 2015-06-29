args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.1
namescale <- 1.15

pipewc_times <- read.table(as.character(args[2]), header=FALSE, sep=" ")
tar_times <- read.table(as.character(args[3]), header=FALSE, sep=" ")
untar_times <- read.table(as.character(args[4]), header=FALSE, sep=" ")
find_times <- read.table(as.character(args[5]), header=FALSE, sep=" ")

pdf(as.character(args[1]), width=7, height=5)

# Graph cars using blue points overlayed by a line
plot(as.integer(pipewc_times), ylim=c(0,2500), type="o", pch=0, lty=1, axes=FALSE, ylab="Time (K cycles)", xlab="# of Application PEs")
lines(as.integer(tar_times), ylim=c(0,2500), type="o", pch=1, lty=2)
lines(as.integer(untar_times), ylim=c(0,2500), type="o", pch=2, lty=3)
lines(as.integer(find_times), ylim=c(0,2500), type="o", pch=3, lty=4)

axis(side = 1, at = 1:5, lab = c("1","2","4","8","16"),
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)
axis(side = 2, at = seq(0, 2500, by = 300), labels = TRUE,
    cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

linetype <- c(1:4)
plotchar <- seq(0, 4, 1)
legend("topleft", c("cat | tr", "tar", "untar", "find"), cex=1, pch=plotchar, lty=linetype)

box(col = 'black')

dev.off()
