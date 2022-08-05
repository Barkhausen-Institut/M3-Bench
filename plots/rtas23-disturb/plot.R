library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))

ggplot(data, aes(fg, bg, fill=diff)) +
  geom_tile() +
  labs(x="Foreground",y="Background") +
  scale_fill_gradient(low="white", high="black") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=5, units="cm")
