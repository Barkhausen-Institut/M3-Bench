library(tidyverse)
library(RColorBrewer)
library(gridExtra)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))
data$latency <- data$latency / 1000000

colors <- brewer.pal(n = 3, name = "Pastel1")
factor_types <- c("Transfers", "RPCs", "Compute")
platforms <- c("SR-IOV", "IPIs", "M³")

get_errors <- function(data) {
    data %>%
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
}

data_s256 <- filter(data, size == "262144")
errors_s256 <- get_errors(data_s256)
ggp1 <- ggplot(data=data_s256, mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  geom_errorbar(data=errors_s256, aes(ymax=latency + sd, ymin=latency - sd), position="dodge", width=.4) +
  scale_fill_manual(values=colors) +
  scale_y_continuous(limits = c(0,7)) +
  labs(x="256 KiB",y="Lat. (M cycles)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), text=element_text(size=10), legend.position="none")

data_s512 <- filter(data, size == "524288")
errors_s512 <- get_errors(data_s512)
ggp2 <- ggplot(data=data_s512, mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  geom_errorbar(data=errors_s512, aes(ymax=latency + sd, ymin=latency - sd), position="dodge", width=.4) +
  scale_fill_manual(values=colors) +
  scale_y_continuous(limits = c(0,7)) +
  labs(x="512 KiB",y="Lat. (M cycles)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), text=element_text(size=10), legend.position="none")

data_s1024 <- filter(data, size == "1048576")
errors_s1024 <- get_errors(data_s1024)
ggp3 <- ggplot(data=data_s1024, mapping=aes(x=platform, y=latency, fill=factor(type, levels=factor_types))) +
  scale_x_discrete(limits=platforms) +
  geom_bar(stat = "summary", fun = "mean", colour="black", size=.1) +
  geom_errorbar(data=errors_s1024, aes(ymax=latency + sd, ymin=latency - sd), position="dodge", width=.4) +
  scale_fill_manual(values=colors) +
  scale_y_continuous(limits = c(0,7)) +
  labs(x="1024 KiB",y="Lat. (M cycles)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), text=element_text(size=10), legend.position="none")

layout <- rbind(c(1,2,3))
ggsave(
  as.character(args[1]),
  arrangeGrob(ggp1, ggp2, ggp3, layout_matrix = layout),
  width=10, height=5, units="cm"
)
