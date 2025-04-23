# 加载所需包
library(ggplot2)
library(ggpubr)
library(openxlsx)

# 读取数据
data <- read.delim("input.txt", header = TRUE, stringsAsFactors = FALSE)
data$taxa <- factor(data$taxa, levels = c("1", "2"))

# ---【统计分析部分】---
group1 <- data[data$taxa == "1", "Density"]
group2 <- data[data$taxa == "2", "Density"]

# Wilcoxon 检验
w_res <- wilcox.test(group1, group2, exact = FALSE)
raw_p <- w_res$p.value
fdr_p <- p.adjust(raw_p, method = "fdr")

# 显著性符号函数
sigFunc <- function(x){
  if (x < 0.001) { "***" } 
  else if (x < 0.01) { "**" }
  else if (x < 0.05) { "*" }
  else { "" }
}

# 计算 Cohen's d
cohen_d <- function(x1, x2) {
  n1 <- length(x1)
  n2 <- length(x2)
  sd1 <- sd(x1)
  sd2 <- sd(x2)
  if (sd1 == 0 | sd2 == 0) return(NA)
  pooled_sd <- sqrt(((n1 - 1)*sd1^2 + (n2 - 1)*sd2^2) / (n1 + n2 - 2))
  d <- (mean(x1) - mean(x2)) / pooled_sd
  return(round(d, 3))
}
d_val <- cohen_d(group1, group2)

# 置信区间（Wilcoxon 无置信区间）
ci_vals <- c(NA, NA)

# 汇总统计结果
summary_df <- data.frame(
  Variable = "AMP Density",
  Group1 = "1",
  Group2 = "2",
  Raw_P = format(raw_p, scientific = TRUE, digits = 5),
  FDR_P = format(fdr_p, scientific = TRUE, digits = 5),
  Signif = sigFunc(fdr_p),
  Cohens_d = d_val,
  CI_Lower = ci_vals[1],
  CI_Upper = ci_vals[2]
)

# 输出 Excel
write.xlsx(summary_df, file = "Density_statistical_results.xlsx", row.names = FALSE)

# ---【绘图部分】---
my_comparisons <- list(c("1", "2"))

p1 <- ggplot(data=data, aes(x=taxa, y=Density)) + 
  geom_violin(aes(fill = taxa), trim = FALSE, alpha = 0.6, width = 0.9, color = NA) +
  stat_summary(fun = mean, geom = "crossbar", width = 0.4, color = "black", size = 0.6) +  # ← 添加这行
  scale_fill_manual(values = c("1" = "#EBBD85", "2" = "#3EAECD")) +
  scale_x_discrete(limits = c("1", "2")) +
  ylab("MGE density (%)") +
  stat_compare_means(comparisons = my_comparisons, method = "wilcox.test", 
                     label = "p.signif", label.y = max(data$Density, na.rm = TRUE) * 1.05,
                     size = 5, family = "serif") +
  theme(
    panel.background = element_rect(fill = "white", colour = "white"),
    panel.grid = element_blank(), 
    axis.title = element_text(color = "black", size = 15),
    axis.ticks = element_line(color = "black"),
    axis.title.x = element_blank(),
    axis.title.y = element_text(colour = "black", size = 15, family = "serif"),
    axis.text.x = element_text(angle = 0, hjust = 0.5, family = "serif"),
    axis.text = element_text(colour = "black", size = 15, family = "serif"),
    axis.line = element_line(colour = "black"),
    legend.position = "none"
  )

# 保存小提琴图
ggsave(p1, filename = "Density_violin_plot.pdf", width = 3.5, height = 3)
