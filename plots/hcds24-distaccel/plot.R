library(tidyverse)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

raw <- read.table(header = TRUE, file = as.character(args[2]))
raw$datasize[raw$datasize == "1024"] <- "1"
raw$datasize[raw$datasize == "2048"] <- "2"
raw$datasize[raw$datasize == "4096"] <- "4"
raw$datasize[raw$datasize == "8192"] <- "8"
raw$datasize[raw$datasize == "16384"] <- "16"
raw$datasize[raw$datasize == "32768"] <- "32"

raw$proto[raw$proto == "cli"] <- "App side"
raw$proto[raw$proto == "srv-central"] <- "Res. side (centralized)"
raw$proto[raw$proto == "srv-dist"] <- "Res. side (distributed)"

raw$latency <- raw$latency / 1000
raw$sd <- raw$sd / 1000

colors <- brewer.pal(n = 4, name = "Pastel1")
colors <- c(colors[1], colors[2], colors[4], colors[3])
columns <- c("1", "2", "4", "8", "16", "32")

print(raw)

app <- raw$latency[raw$proto == "App side"]
cen <- raw$latency[raw$proto == "Res. side (centralized)"]
dis <- raw$latency[raw$proto == "Res. side (distributed)"]
print("App vs. resource side (dist.):")
print(app / dis)
print("resource side (cent.) vs. resource side (dist.):")
print(cen / dis)

ggplot(data=raw, mapping=aes(x=datasize, y=latency, fill=proto)) +
  scale_x_discrete(limits=columns) +
  geom_bar(stat="summary", position=position_dodge(), colour="black", size=.1) +
  geom_errorbar(aes(ymin=latency-sd, ymax=latency+sd), width=.4, position=position_dodge(.9)) +
  scale_fill_manual(values=colors) +
  labs(x="Data size (KiB)",y="Latency (µs)") +
  theme_bw() +
  theme(text=element_text(size=10), legend.title=element_blank(), legend.margin=margin(0,0,0,0))

ggsave(as.character(args[1]), width=12, height=6, units="cm", device=cairo_pdf)
