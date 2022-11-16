library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))
data$latency <- data$latency / 1000000

colors <- brewer.pal(n = 3, name = "Pastel1")
factor_types <- c("Transfers", "RPCs", "Compute")
platforms <- c("SR-IOV", "MMU+IPIs", "M³")

ggplot(data=data, mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  coord_flip() +
  scale_fill_manual(values=colors) +
  labs(x="Platform",y="Latency (M cycles)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=3, units="cm")
