library(tidyverse)
library(RColorBrewer)
library(gridExtra)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))
data$latency <- data$latency / 1000000

colors <- brewer.pal(n = 3, name = "Pastel1")
factor_types <- c("Transfers", "RPCs", "Compute")
platforms <- c("SR-IOV", "MMU+IPIs", "M³")

ggp1 <- ggplot(data=filter(data, size == "262144"), mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  scale_fill_manual(values=colors) +
  scale_y_continuous(limits = c(0,8)) +
  labs(x="Platform",y="Lat. (M cycles)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), text=element_text(size=10), legend.position="none")

ggp2 <- ggplot(data=filter(data, size == "524288"), mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  scale_fill_manual(values=colors) +
  scale_y_continuous(limits = c(0,8)) +
  labs(x="Platform",y="Lat. (M cycles)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), text=element_text(size=10), legend.position="none")

ggp3 <- ggplot(data=filter(data, size == "1048576"), mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  scale_fill_manual(values=colors) +
  scale_y_continuous(limits = c(0,8)) +
  labs(x="Platform",y="Lat. (M cycles)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), text=element_text(size=10), legend.position="none")

layout <- rbind(c(1,2,3))
ggsave(
  as.character(args[1]),
  arrangeGrob(ggp1, ggp2, ggp3, layout_matrix = layout),
  width=8, height=4, units="cm"
)
