library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

membw <- read.table(header = TRUE, file = as.character(args[2]))
print(membw)

colors <- brewer.pal(n = 4, name = "Pastel1")

ggplot(data=membw, mapping=aes(x=clients, y=time, fill=type)) +
  geom_bar(stat="identity", position="dodge", colour="black", linewidth=.3) +
  scale_fill_manual(values=colors) +
  scale_x_continuous(breaks=c(1, 2, 3, 4, 5, 6)) +
  scale_y_continuous(breaks=c(0, 2, 4, 6, 8, 10)) +
  labs(x="Number of clients",y="Max. req. time (ms)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))
ggsave(as.character(args[1]), width=12, height=4, units="cm")
