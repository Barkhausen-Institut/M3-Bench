library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.2
namescale <- 1.2

osname <- as.character(args[2])

times <- read.table(as.character(args[3]), header=TRUE, sep=" ") / 1000000

pdf(as.character(args[1]), width=7, height=3.5)

par(mar=c(3.1,5.1,2.1,2.1))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

barplot(as.matrix(times), beside=F,
    ylim=c(0,3), space=c(0.3, 0.05, 0.05), ylab="Time (M cycles)",
    cex.names=namescale,
    names.arg=c("Linux",osname,paste(osname,"accelerator",sep="+")))
box(col = 'black')

legend("topright", c("FFT", "Xfers", "OS"), cex=namescale, fill=rev(gray.colors(3)))

dev.off()
embed_fonts(as.character(args[1]))
