library(tidyverse)
library(RColorBrewer)

cell_label <- function(diff) {
  rounded <- round(diff, 2)
  rounded[rounded == -0.0] <- 0
  return(sprintf("% .2f", rounded))
}

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))

ggplot(data, aes(fg, bg, fill=diff)) +
  geom_tile() +
  geom_text(aes(label = cell_label(diff))) +
  labs(x="Foreground",y="Background") +
  scale_fill_gradient(low="white", high="darkgray", limits = c(-.1, 5)) +
  theme_bw() +
  theme(text=element_text(size=14), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=5, units="cm")