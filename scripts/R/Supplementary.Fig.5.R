# 加载所需库
library(openxlsx)

# 设置文件路径
alpha_index <- "input.txt"

# 读取数据，只保留 LAB 和 Microbes 两组
mydata <- read.delim(alpha_index, header=TRUE, stringsAsFactors=FALSE, check.names=FALSE)

mydata <- mydata[mydata$Group.name %in% c("LAB", "Microbes"), ]
mydata$Group.name <- factor(mydata$Group.name, levels=c("LAB", "Microbes"))

# 定义显著性符号函数
sigFunc <- function(x){
  if (x < 0.001) { "***" } 
  else if (x < 0.01) { "**" }
  else if (x < 0.05) { "*" }
  else { "" }
}

# 定义Cohen's d
cohen_d <- function(x1, x2) {
  n1 <- length(x1)
  n2 <- length(x2)
  pooled_sd <- sqrt(((n1 - 1) * var(x1) + (n2 - 1) * var(x2)) / (n1 + n2 - 2))
  d <- (mean(x1) - mean(x2)) / pooled_sd
  return(round(d, 3))
}

# 定义置信区间函数
conf_interval <- function(x1, x2) {
  t_result <- t.test(x1, x2)
  return(round(t_result$conf.int, 3))
}

# 开始分析每一个氨基酸列
aa_cols <- colnames(mydata)[!(colnames(mydata) %in% c("sample.id", "Group.name", "colour"))]

results <- list()
raw_pvals <- c()

for (aa in aa_cols) {
  group1 <- mydata[mydata$Group.name == "LAB", aa]
  group2 <- mydata[mydata$Group.name == "Microbes", aa]
  
  # Wilcoxon检验
  p_raw <- wilcox.test(group1, group2)$p.value
  raw_pvals <- c(raw_pvals, p_raw)
  
  results[[aa]] <- list(
    aa = aa,
    v1 = group1,
    v2 = group2,
    raw_p = p_raw
  )
}

# FDR校正
fdr_pvals <- p.adjust(raw_pvals, method="fdr")

# 汇总统计结果
summary_table <- data.frame()
for (i in seq_along(aa_cols)) {
  aa <- aa_cols[i]
  res <- results[[aa]]
  ci <- conf_interval(res$v1, res$v2)
  d <- cohen_d(res$v1, res$v2)
  fdr <- fdr_pvals[i]
  
  summary_table <- rbind(summary_table, data.frame(
    AA = aa,
    Group1 = "LAB",
    Group2 = "Microbes",
    Raw_P = format(res$raw_p, scientific=TRUE, digits=5),
    FDR_P = format(fdr, scientific=TRUE, digits=5),
    Signif = sigFunc(fdr),
    Cohens_d = d,
    CI_Lower = ci[1],
    CI_Upper = ci[2]
  ))
}

# 输出Excel文件
write.xlsx(summary_table, file="LAB_vs_Microbes_AA_Differences.xlsx", row.names=FALSE)

