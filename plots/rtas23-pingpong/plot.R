library(tidyverse)
library(RColorBrewer)
library(gridExtra)

args <- commandArgs(trailingOnly = TRUE)

data <- read.table(header = TRUE, file = as.character(args[2]))
data$latency <- data$latency / 1000

printf <- function(...) invisible(print(sprintf(...)))
detect_outlier <- function(x) {
    # calculate first quantile
    Quantile1 <- quantile(x, probs=.25)
    # calculate third quantile
    Quantile3 <- quantile(x, probs=.75)
    # calculate inter quartile range
    IQR = Quantile3-Quantile1
    # return true or false
    x > Quantile3 + (IQR*1.5) | x < Quantile1 - (IQR*1.5)
}

micro_no_outlier <- data.frame()
micro_plos <- list(
    c("M³", "FPGA"),
    c("M³", "S-RISCV"),
    c("NOVA", "S-x86"),
    c("M³", "S-x86"),
    c("L4Re", "H-ARM"),
    c("NOVA", "H-x86")
)
for(po in micro_plos) {
    # remove measurements that are considered outliers for this specific OS and platform
    tmp <- data[(data$os == po[1] & data$platform == po[2]),]
    tmp <- tmp[!detect_outlier(tmp$latency), ]
    # join them to the dataframe
    micro_no_outlier <- rbind(micro_no_outlier, tmp)
}

lx_no_outlier <- data.frame()
lx_plos <- list(
    c("Linux", "S-RISCV"),
    c("Linux", "S-x86"),
    c("Linux", "H-NIC")
)
for(po in lx_plos) {
    # remove measurements that are considered outliers for this specific OS and platform
    tmp <- data[(data$os == po[1] & data$platform == po[2]),]
    tmp <- tmp[!detect_outlier(tmp$latency), ]
    # join them to the dataframe
    lx_no_outlier <- rbind(lx_no_outlier, tmp)
}

# cols <- c("hw", "gem5-riscv", "gem5-x86_64", "sriov", "arm", "x86pc")
# colnames <- c("FPGA", "gem5 (RISC-V)", "gem5 (x86-64)", "SR-IOV HW", "ARM HW", "x86 HW")

# build summary for data with outliers
data_sum <- data %>%
    group_by(platform, os) %>%
    summarise(
        n=n(),
        mean=mean(latency),
        min=min(latency),
        max=max(latency),
        sd=sd(latency)
    )

cols <- c("FPGA-M³", "S-RISCV-M³", "S-x86-NOVA", "S-x86-M³", "H-ARM-L4Re", "H-x86-NOVA")
colnames <- c("FPGA", "S-RISCV", "S-x86", "S-x86", "H-ARM", "H-x86")

# build summary for data without outliers (for the plot)
micro_no_outlier <- micro_no_outlier %>%
    group_by(platform, os) %>%
    summarise(
        n=n(),
        mean=mean(latency),
        sd=sd(latency)
    )
micro_no_outlier$platformos <- paste(micro_no_outlier$platform, micro_no_outlier$os, sep="-")

micro_no_outlier <- micro_no_outlier %>%
  mutate(platformos=factor(platformos, levels=cols))
print(micro_no_outlier)
ggp1 <- ggplot(micro_no_outlier, aes(x=platformos, y=mean, colour=os, fill=os)) +
    scale_x_discrete(labels = colnames) +
    scale_fill_brewer(palette = "Pastel1") +
    labs(x="Platform", y="Latency (K cycles)") +
    geom_bar(stat='identity', position="dodge", colour="black", size=.1, show.legend=F) +
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.1, position=position_dodge(.9), colour="black") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

# ----

cols <- c("S-RISCV-Linux", "S-x86-Linux", "H-NIC-Linux")
colnames <- c("S-RISCV", "S-x86", "H-NIC")

# build summary for data without outliers (for the plot)
lx_no_outlier <- lx_no_outlier %>%
    group_by(platform, os) %>%
    summarise(
        n=n(),
        mean=mean(latency),
        sd=sd(latency)
    )
lx_no_outlier$platformos <- paste(lx_no_outlier$platform, lx_no_outlier$os, sep="-")
print(lx_no_outlier)

lx_no_outlier <- lx_no_outlier %>%
  mutate(platformos=factor(platformos, levels=cols))
ggp2 <- ggplot(lx_no_outlier, aes(x=platformos, y=mean, colour=os, fill=os)) +
    scale_x_discrete(labels = colnames) +
    scale_fill_brewer(palette = "Dark2") +
    labs(x="Platform", y="Latency (K cycles)") +
    geom_bar(stat='identity', position="dodge", colour="black", size=.1, show.legend=F) +
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.1, position=position_dodge(.9), colour="black") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

data_sum_warm <- rbind(micro_no_outlier, lx_no_outlier)
for(po in micro_plos) {
    sum_cold <- data_sum[(data_sum$os == po[1] & data_sum$platform == po[2]),]
    # sum_warm <- data_sum_warm[(data_sum_warm$os == po[1] & data_sum_warm$platform == po[2]),]
    printf(
        "\textbf{%s} & %s & %.0f & %.0f & %.0f & %.0f \\",
        po[1], po[2],
        sum_cold$mean * 1000, sum_cold$min * 1000, sum_cold$max * 1000, sum_cold$sd * 1000
    )
}
for(po in lx_plos) {
    sum_cold <- data_sum[(data_sum$os == po[1] & data_sum$platform == po[2]),]
    printf(
        "\textbf{%s} & %s & %.0f & %.0f & %.0f & %.0f \\",
        po[1], po[2],
        sum_cold$mean * 1000, sum_cold$min * 1000, sum_cold$max * 1000, sum_cold$sd * 1000
    )
}

# data_no_outlier <- data_no_outlier %>%
#   mutate(platform=factor(platform, levels=cols))
# ggplot(data_no_outlier, aes(x=platform, y=latency, colour=os, fill=os)) +
#     scale_x_discrete(labels = colnames) +
#     scale_fill_discrete(name = "OS", labels = c("Linux", "M³")) +
#     labs(x="Platform", y="Latency (cycles)") +
#     geom_violin() +
#     theme_bw()

layout <- rbind(c(1,1,1,1,1,2,2,2))
ggsave(
    as.character(args[1]),
    arrangeGrob(ggp1, ggp2, layout_matrix = layout),
    width=14, height=7, units="cm"
)
