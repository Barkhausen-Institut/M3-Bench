error.bar <- function(mp, means, stddevs, horizontal=F) {
    stDevs <- matrix(stddevs, length(stddevs))
    # Plot the vertical lines of the error bars
    # The vertical bars are plotted at the midpoints
    if(horizontal)
        segments(means - stDevs, mp, means + stDevs, mp, lwd=1)
    else
        segments(mp, means - stDevs, mp, means + stDevs, lwd=1)
    # Now plot the horizontal bounds for the error bars
    # 1. The lower bar
    if(horizontal)
        segments(means - stDevs, mp - 0.1, means - stDevs, mp + 0.1, lwd=1)
    else
        segments(mp - 0.1, means - stDevs, mp + 0.1, means - stDevs, lwd=1)
    # 2. The upper bar
    if(horizontal)
        segments(means + stDevs, mp - 0.1, means + stDevs, mp + 0.1, lwd=1)
    else
        segments(mp - 0.1, means + stDevs, mp + 0.1, means + stDevs, lwd=1)
}

bar.break <- function(mp, idx, ypos, height, skew) {
    xvals <- c(mp[idx] - 0.5, mp[idx] + 0.5)
    lines(xvals, c(ypos - height - skew, ypos - height + skew), lwd=1, col='black')
    lines(xvals, c(ypos - skew, ypos + skew), lwd=5, col='white')
    lines(xvals, c(ypos + height - skew, ypos + height + skew), lwd=1, col='black')
}

add_legend <- function(...) {
    opar <- par(fig=c(0, 1, 0, 1), oma=c(0, 0, 0, 0), mar=c(0, 0, 0, 0), new=T)
    on.exit(par(opar))
    plot(0, 0, type='n', bty='n', xaxt='n', yaxt='n')
    legend(...)
}
