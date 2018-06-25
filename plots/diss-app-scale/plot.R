library(extrafont)

args <- commandArgs(trailingOnly = TRUE)
scaling <- 1.8
namescale <- 1.8

times <- list()
for(i in 1:7) {
    times[[i]] <- read.table(as.character(args[i + 1]), header=T, sep=" ")
}

pdf(as.character(args[1]), width=8, height=6, useDingbats=FALSE)
par(cex.lab=scaling, cex.axis=scaling, cex.main=scaling, cex.sub=scaling)

layout(matrix(c(1,2,3,4,5,6), 3, 2, byrow = TRUE),
    widths=c(1.08,1), heights=c(1.25,1,1))

par(mar=c(5,6,4,0))

subs <- c("tar", "untar", "shasum & sort", "find", "SQLite", "LevelDB")
for(i in 1:6) {
    if(i > 1)
        par(mar=c(5,if(i %% 2 == 1) 6 else 4,if(i == 2) 4 else 0.5,0))

    plot(c(1,2,4,8,16,32), times[[i]]$s1, ylim=c(0,100), type="o", pch=0, axes=FALSE, xlab="", ylab="")
    abline(h=c(seq(0,100,25)), col="gray80")
    par(new=T)

    plot(c(1,2,4,8,16,32), times[[i]]$s1, ylim=c(0,100), type="o", pch=0, axes=FALSE, ylab="", xlab="")
    lines(c(1,2,4,8,16,32), times[[i]]$s2, ylim=c(0,100), type="o", pch=1, lty="dashed")
    lines(c(1,2,4,8,16,32), times[[i]]$s4, ylim=c(0,100), type="o", pch=2, lty="dotted")
    lines(c(1,2,4,8,16,32), times[[i]]$s8, ylim=c(0,100), type="o", pch=3, lty="dashed")
    if(i == 3) {
        lines(c(1,2,4,8,16,32), times[[7]]$s1, ylim=c(0,100), type="o", pch=0)
        lines(c(1,2,4,8,16,32), times[[7]]$s2, ylim=c(0,100), type="o", pch=1, lty="dashed")
        lines(c(1,2,4,8,16,32), times[[7]]$s4, ylim=c(0,100), type="o", pch=2, lty="dotted")
        lines(c(1,2,4,8,16,32), times[[7]]$s8, ylim=c(0,100), type="o", pch=3, lty="dashed")
    }

    axis(side = 1, at = seq(0, 32, 4), labels = TRUE, line=-0.3)
    axis(side = 2, at = seq(0, 100, 25), labels = TRUE, las=1)

    if(i %% 2 == 1)
        title(ylab = "Paral. eff. (%)", mgp=c(4, 1, 0))
    title(xlab = paste("# of applications (", subs[[i]] ,")"), mgp=c(2.7, 1, 0))
}

# legend
par(fig=c(0,1,0,1), oma=c(0,0,0,0), mar=c(0,0,0,0), new=TRUE)

plot(0, 0, type="n", bty="n", xaxt="n", yaxt="n")
linetype <- c(1:4)
plotchar <- seq(0, 3, 1)
legend("top", c("1 srv", "2 srv", "4 srv", "8 srv"), horiz=T, bty="n",
    cex=namescale, pch=plotchar, lty=linetype, inset=c(0,0))

dev.off()
embed_fonts(as.character(args[1]))
