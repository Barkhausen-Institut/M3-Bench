library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))

ggplot(data, aes(fg, bg, fill=diff)) +
  geom_tile() +
  geom_text(aes(label = sprintf("% .2f", round(diff, 2)))) +
  labs(x="Foreground",y="Background") +
  scale_fill_gradient(low="white", high="darkgray", limits = c(-.1, 5)) +
  theme_bw() +
  theme(text=element_text(size=14), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=5, units="cm")