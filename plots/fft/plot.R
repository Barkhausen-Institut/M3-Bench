args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.3
namescale <- 1.15

times <- read.table(as.character(args[2]), header=TRUE, sep=" ") / 1000

pdf(as.character(args[1]), width=7, height=5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

barplot(as.matrix(times), beside=F,
    ylim=c(0,3000), space=c(0.3, 0, 0), ylab="Time (K cycles)",
    cex.names=namescale,
    names.arg=c("Linux","M3","M3+accelerator"))
box(col = 'black')

legend("topright", c("FFT", "Data xfers", "Remaining"), cex=1, fill=rev(gray.colors(3)))

dev.off()
