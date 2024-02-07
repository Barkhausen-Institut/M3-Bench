library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

membw <- read.table(header = TRUE, file = as.character(args[2]))
membw$type <- factor(membw$type, levels = c("No-prios", "Low", "High"))
membw <- membw %>%
    group_by(clients, type) %>%
    summarize(time = round(max(time), 3))
print(membw)

colors <- brewer.pal(n = 4, name = "Pastel1")

membw |>
  mutate(
    # place onto bar if the bar is too high to display it on top
    place = if_else(time > 7, 1, 0),
    # add some spacing to labels since we cant use nudge_x anymore
    human_time = paste(" ", time, " ")
  ) |>
  ggplot(mapping=aes(x=clients, y=time, fill=type)) +
    geom_bar(stat="identity", position="dodge", colour="black", linewidth=.3) +
    geom_text(aes(label=human_time, hjust=place), position=position_dodge2(width=.9), size=2.5, angle=90) +
    scale_fill_manual(values=colors) +
    scale_x_continuous(breaks=c(1, 2, 3, 4, 5, 6)) +
    scale_y_continuous(breaks=c(0, 2, 4, 6, 8, 10)) +
    labs(x="Number of clients",y="Max. req. time (ms)") +
    theme_bw() +
    theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))
ggsave(as.character(args[1]), width=12, height=4, units="cm")
