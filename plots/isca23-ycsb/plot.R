library(tidyverse)
library(data.table)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))
data$latency <- data$latency / 1000000

colors <- brewer.pal(n = 3, name = "Pastel1")
factor_types <- c("Transfers", "RPCs", "Compute")
platforms <- c("SR-IOV+IOMMU", "M³", "IPIs+MMU")

errors <- data %>%
    group_by(platform, type) %>%
    summarise(
      total=mean(latency),
      sd=sd(latency)
    ) %>%
    group_by(platform) %>%
    summarise(
        n=n(),
        latency=sum(total),
        sd=sum(sd),
        type=""
    )

print(errors)

ggplot(data=data, mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  geom_errorbar(data=errors, aes(ymax=latency + sd, ymin=latency - sd), position="dodge", width=.4) +
  coord_flip() +
  scale_fill_manual(values=colors) +
  labs(x="Platform",y="Latency (M cycles)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=3, units="cm")
