library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
limits <- c(4, 16, 64, 256, 1024, 4096)

prepare_dataframe <- function(data, limit) {
  data <- subset(data, fg %in% c("memory"))
  data$fg <- limit
  return(data)
}

data <- read.table(header = TRUE, file = as.character(args[2]))
data <- prepare_dataframe(data, limits[1])
for(i in 2:length(limits)) {
  tmp <- read.table(header = TRUE, file = as.character(args[i + 1]))
  tmp <- prepare_dataframe(tmp, limits[i])
  data <- rbind(data, tmp)
}

cols <- c("4096", "1024", "256", "64", "16", "4")
data_sorted <- data %>%
  mutate(fg=factor(fg, levels=cols))

ggplot(data_sorted, aes(fg, bg, fill=diff)) +
  geom_tile() +
  geom_text(aes(label = sprintf("% .2f", round(diff, 2)))) +
  labs(x="NoC-bandwidth limit (MiB/s)",y="Background") +
  scale_fill_gradient(low="white", high="darkgray", limits = c(-.1, 5)) +
  theme_bw() +
  theme(text=element_text(size=14), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=5, units="cm")
