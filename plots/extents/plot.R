args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.15

read_times <- read.table(as.character(args[2]), header=FALSE, sep=" ")
write_times <- read.table(as.character(args[3]), header=FALSE, sep=" ")

pdf(as.character(args[1]), width=7, height=3.5)
par(mar=c(5.1,5.1,2.1,2.1))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

# Graph cars using blue points overlayed by a line
plot(as.integer(read_times), ylim=c(0,1500), type="o", pch=0, axes=FALSE, ylab="Time (K cycles)", xlab="Blocks per extent")
lines(as.integer(write_times), ylim=c(0,1500), type="o", pch=1, lty="dashed")

axis(side = 1, at = 1:8, lab = c("16","32","64","128","256","512","1024","2048"))
axis(side = 2, at = seq(0, 1500, by = 300), labels = TRUE)

linetype <- c(1:2)
plotchar <- seq(0, 2, 1)
legend("topright", c("Reading", "Writing"), cex=namescale, pch=plotchar, lty=linetype)

box(col = 'black')

dev.off()
