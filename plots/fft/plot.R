args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.1
namescale <- 1.15

osname <- as.character(args[2])

times <- read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=3.5)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

barplot(as.matrix(times), beside=F,
    ylim=c(0,3), space=c(0.3, 0, 0), ylab="Time (M cycles)",
    cex.names=namescale,
    names.arg=c("Linux",osname,paste(osname,"accelerator",sep="+")))
box(col = 'black')

legend("topright", c("FFT", "Data xfers", "OS overhead"), cex=1, fill=rev(gray.colors(3)))

dev.off()
