library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

df <- read.table(header = TRUE, file = as.character(args[2]))

colors <- brewer.pal(n = 3, name = "Pastel1")[1:2]
columns <- c("mwait", "umwait", "DTU-sleep")

ggplot(data=df, mapping=aes(x=mechanism, y=latency, fill=op)) +
  scale_x_discrete(limits=columns) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  coord_flip() +
  scale_fill_manual(values=colors) +
  labs(x="Mechanism",y="Latency (cycles)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))
ggsave(as.character(args[1]), width=12, height=3, units="cm")
