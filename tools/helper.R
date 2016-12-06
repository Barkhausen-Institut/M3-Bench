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

add_legend <- function(...) {
    opar <- par(fig=c(0, 1, 0, 1), oma=c(0, 0, 0, 0), mar=c(0, 0, 0, 0), new=T)
    on.exit(par(opar))
    plot(0, 0, type='n', bty='n', xaxt='n', yaxt='n')
    legend(...)
}
