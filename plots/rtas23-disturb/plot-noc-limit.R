library(tidyverse)
library(RColorBrewer)

prepare_dataframe <- function(data, limit) {
  data <- subset(data, fg %in% c("memory"))
  data$fg <- limit
  return(data)
}

cell_label <- function(diff) {
  rounded <- round(diff, 2)
  rounded[rounded == -0.0] <- 0
  return(sprintf("% .2f", rounded))
}

args <- commandArgs(trailingOnly = TRUE)
limits <- c(8, 32, 128, 512, 2048)

data <- read.table(header = TRUE, file = as.character(args[2]))
data <- prepare_dataframe(data, limits[1])
for(i in 2:length(limits)) {
  tmp <- read.table(header = TRUE, file = as.character(args[i + 1]))
  tmp <- prepare_dataframe(tmp, limits[i])
  data <- rbind(data, tmp)
}

cols <- c("2048", "512", "128", "32", "8")
data_sorted <- data %>%
  mutate(fg=factor(fg, levels=cols))

ggplot(data_sorted, aes(fg, bg, fill=diff)) +
  geom_tile() +
  geom_text(aes(label = cell_label(diff))) +
  labs(x="NoC-bandwidth limit (MiB/s)",y="Background") +
  scale_fill_gradient(low="white", high="darkgray", limits = c(-.1, 5)) +
  theme_bw() +
  theme(text=element_text(size=14), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=4.2, units="cm")
