library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

df <- read.table(header = TRUE, file = as.character(args[2]))

colors <- brewer.pal(n = 4, name = "Blues")
colors <- c(colors[2], colors[1])
columns <- c("mwait", "umwait", "DTU-sleep")

ggplot(data=df, mapping=aes(x=mechanism, y=latency, fill=forcats::fct_rev(op))) +
  scale_x_discrete(limits=columns) +
  geom_bar(stat = "summary", fun = "mean", colour="black", linewidth=.3) +
  coord_flip() +
  scale_fill_manual(values=colors) +
  labs(x="", y="Latency (cycles)") +
  theme_bw() +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))
ggsave(as.character(args[1]), width=12, height=2.4, units="cm")
