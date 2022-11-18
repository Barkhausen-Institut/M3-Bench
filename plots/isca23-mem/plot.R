library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

raw <- read.table(header = TRUE, file = as.character(args[2]))
raw$datasize[raw$datasize == "4096b"] <- "4K"
raw$datasize[raw$datasize == "65536b"] <- "64K"
raw$datasize[raw$datasize == "1048576b"] <- "1M"
raw$datasize[raw$datasize == "16777216b"] <- "16M"
raw$datasize[raw$datasize == "268435456b"] <- "256M"

data <- filter(raw, platform != "SR-IOV+IOMMU")
sriov <- filter(raw, platform == "SR-IOV+IOMMU")

colors <- brewer.pal(n = 4, name = "Pastel1")
columns <- c("1b", "16b", "256b", "4K", "64K", "1M", "16M", "256M")

for(v in columns) {
    sub <- filter(sriov, datasize == v)
    avg <- round(mean(sub$latency))
    stddev <- round(sd(sub$latency))
    data[nrow(data) + 1, 1:2] = c("SR-IOV+IOMMU", v)
    data[nrow(data), 3:4] = c(avg, stddev)
}

print(data)

ggplot(data=data, mapping=aes(x=datasize, y=latency, fill=platform)) +
  scale_x_discrete(limits=columns) +
  geom_bar(stat="summary", position=position_dodge(), colour="black", size=.1) +
  geom_errorbar(aes(ymin=latency-sd, ymax=latency+sd), width=.4, position=position_dodge(.9)) +
  scale_y_log10() +
  scale_fill_manual(values=colors) +
  labs(x="Data size (bytes)",y="Latency (cycles)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=5, units="cm")
