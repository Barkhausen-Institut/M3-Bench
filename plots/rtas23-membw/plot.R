library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

membw <- read.table(header = TRUE, file = as.character(args[2]))
membw$throughput <- membw$throughput / 1000000000

colors <- brewer.pal(n = 3, name = "Pastel1")[1:2]
columns <- c("-","1024","512","256","128","64","32","16")

ggplot(data=membw, mapping=aes(x=limit, y=throughput, fill=load)) +
  scale_x_discrete(limits=columns) +
  geom_bar(stat="identity", position="dodge", colour="black", size=.3) +
  scale_fill_manual(values=colors) +
  labs(x="Bandwidth limit for BG (MB/s)",y="Throughput (GB/s)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))
ggsave(as.character(args[1]), width=12, height=5, units="cm")
