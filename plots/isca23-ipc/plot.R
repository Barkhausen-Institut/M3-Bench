library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

ipc <- read.table(header = TRUE, file = as.character(args[2]))

colors <- brewer.pal(n = 3, name = "Pastel1")
columns <- c("1b", "4b", "16b", "64b", "256b", "1024b", "2032b")

ggplot(data=ipc, mapping=aes(x=msgsize, y=latency, fill=platform)) +
  scale_x_discrete(limits=columns) +
  geom_bar(stat="identity", position=position_dodge(), colour="black", size=.1) +
  scale_y_log10() +
  scale_fill_manual(values=colors) +
  labs(x="Message size (bytes)",y="Latency (cycles)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=5, units="cm")
