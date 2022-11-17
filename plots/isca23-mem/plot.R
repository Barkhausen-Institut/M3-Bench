library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

ipc <- read.table(header = TRUE, file = as.character(args[2]))
ipc$datasize[ipc$datasize == "4096b"] <- "4KiB"
ipc$datasize[ipc$datasize == "65536b"] <- "64KiB"
ipc$datasize[ipc$datasize == "1048576b"] <- "1MiB"
ipc$datasize[ipc$datasize == "16777216b"] <- "16MiB"
ipc$datasize[ipc$datasize == "268435456b"] <- "256MiB"

colors <- brewer.pal(n = 4, name = "Pastel1")
columns <- c("1b", "16b", "256b", "4KiB", "64KiB", "1MiB", "16MiB", "256MiB")

ggplot(data=ipc, mapping=aes(x=datasize, y=latency, fill=platform)) +
  scale_x_discrete(limits=columns) +
  geom_bar(stat="summary", position=position_dodge(), colour="black", size=.1) +
  scale_y_log10() +
  scale_fill_manual(values=colors) +
  labs(x="Data size (bytes)",y="Latency (cycles)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=5, units="cm")
