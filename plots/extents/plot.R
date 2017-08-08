library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.2
namescale <- 1.1

read_times = scan(args[2]) / 1000
write_times = scan(args[3]) / 1000

pdf(as.character(args[1]), width=7, height=3, useDingbats=FALSE)
par(mar=c(5.1,5.1,2.1,2.1))
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

# Graph cars using blue points overlayed by a line
plot(read_times, ylim=c(0,2000), type="o", pch=0, axes=FALSE, ylab="Time (K cycles)", xlab="Blocks per extent")
lines(write_times, ylim=c(0,2000), type="o", pch=1, lty="dashed")

axis(side = 1, at = 1:8, lab = c("16","32","64","128","256","512","1024","2048"))
axis(side = 2, at = seq(0, 2000, by = 500), labels = TRUE)

linetype <- c(1:2)
plotchar <- seq(0, 2, 1)
legend("topright", c("Reading", "Writing"), horiz=T, cex=namescale, pch=plotchar, lty=linetype)

box(col = 'black')

dev.off()
embed_fonts(as.character(args[1]))
