# 加载所需库
library(ggplot2)
library(ggsignif)
library(openxlsx)

# 设置输入文件（可改为 args）
alpha_index <- "input.xls"
group_col <- "group.color.list"

# 读取数据
x2 <- read.table(group_col, sep="\t", head=F, comment.char="", stringsAsFactors=F)
names(x2) <- c("sample.id", "Group.name", "colour")
xx <- read.table(alpha_index, head=T, sep="\t", comment="")
mydata <- merge(x2, xx, by.y="sample.id")
rownames(mydata) <- mydata$sample.id
write.table(mydata, "data.xls", sep='\t', quote=FALSE, col.names=NA)

# 分组处理
a <- unique(mydata$Group.name)
mydata$Group.name <- factor(mydata$Group.name, levels=as.vector(a))
color <- x2$colour[match(c("LAB","Archaic_animal","human","Microbes","public_data"), x2$Group.name)]

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
  mean1 <- mean(x1)
  mean2 <- mean(x2)
  sd1 <- sd(x1)
  sd2 <- sd(x2)
  pooled_sd <- sqrt(((n1 - 1)*sd1^2 + (n2 - 1)*sd2^2) / (n1 + n2 - 2))
  d <- (mean1 - mean2) / pooled_sd
  return(round(d, 3))
}

# 置信区间
conf_interval <- function(x1, x2) {
  t_result <- t.test(x1, x2)
  return(round(t_result$conf.int, 3))
}

# 获取指标名
cnames <- colnames(mydata)

# 收集所有比较的P值（用于FDR校正）
all_pvalues <- c()
all_comparisons <- list()

# 第1轮：收集所有 P 值和组对信息
for (i in 4:length(cnames)) {
  compared.group <- list(
    c("LAB", "Archaic_animal"), 
    c("LAB", "Microbes"), 
    c("LAB", "human"), 
    c("LAB", "public_data")
  )
  for (grp in compared.group) {
    group1 <- grp[1]
    group2 <- grp[2]
    val1 <- mydata[mydata$Group.name == group1, i]
    val2 <- mydata[mydata$Group.name == group2, i]
    wilcox_p <- wilcox.test(val1, val2)$p.value
    all_pvalues <- c(all_pvalues, wilcox_p)
    all_comparisons[[length(all_comparisons)+1]] <- list(
      index=cnames[i], g1=group1, g2=group2, v1=val1, v2=val2, raw_p=wilcox_p
    )
  }
}

# 第2轮：FDR校正
fdr_pvalues <- p.adjust(all_pvalues, method="fdr")

# 第3轮：结果整理 + 绘图
result_list <- list()
f_index <- 1

for (i in 4:length(cnames)) {
  compared.group <- list(
    c("LAB", "Archaic_animal"), 
    c("LAB", "Microbes"), 
    c("LAB", "human"), 
    c("LAB", "public_data")
  )
  
  # 画图
  p <- ggplot(data=mydata, aes(x=Group.name, y=mydata[,i]), fill=unique(Group.name)) + 
    geom_boxplot(fill=color, alpha=0.3, outlier.shape=NA, size=0.3) +
    labs(x="", y=cnames[i]) +
    scale_x_discrete(limits=c("LAB", "Archaic_animal", "human", "Microbes", "public_data")) +
    theme(
      panel.background = element_rect(fill="white", colour="black"),
      panel.grid = element_blank(), 
      axis.title = element_text(color="black", size=14),
      axis.ticks = element_line(color="black"), 
      axis.title.x = element_text(colour="black", size=14),
      axis.title.y = element_text(colour="black", size=22),
      axis.text.x = element_text(angle=45, hjust=1),
      axis.text = element_text(colour="black", size=14),
      axis.line = element_line(colour = "black"),
      legend.position = "none"
    ) +
    geom_signif(test="wilcox.test", comparisons=compared.group, step_increase=0.1,
                map_signif_level=sigFunc, margin_top=0.05)
  
  # 输出统计结果
  for (k in 1:4) {
    comp <- all_comparisons[[f_index]]
    raw_p <- comp$raw_p
    fdr_p <- fdr_pvalues[f_index]
    d_val <- cohen_d(comp$v1, comp$v2)
    ci_val <- conf_interval(comp$v1, comp$v2)
    p_star <- sigFunc(fdr_p)
    
    result_list[[length(result_list) + 1]] <- data.frame(
      Index = comp$index,
      Group1 = comp$g1,
      Group2 = comp$g2,
      Raw_P = format(raw_p, scientific=TRUE, digits=5),
      FDR_P = format(fdr_p, scientific=TRUE, digits=5),
      Signif = p_star,
      Cohens_d = d_val,
      CI_Lower = ci_val[1],
      CI_Upper = ci_val[2]
    )
    
    cat(">>>", comp$index, "-", comp$g1, "vs", comp$g2, "\n")
    cat("  Raw P:", format(raw_p, scientific=TRUE, digits=5),
        "| FDR P:", format(fdr_p, scientific=TRUE, digits=5),
        "| Cohen's d:", d_val, "| CI:", ci_val[1], "~", ci_val[2], "|", p_star, "\n\n")
    
    f_index <- f_index + 1
  }
  
  # 保存图像
  png(file=paste0(cnames[i], ".png"), res=72*3, width=200*3, height=300*3)
  ggsave(p, file=paste0(cnames[i], "-boxplot.pdf"), width=3, height=4, limitsize=F)
  print(p)
  dev.off()
}

# 写入 Excel 表格
effect_df <- do.call(rbind, result_list)
write.xlsx(effect_df, file="effect_size_results.xlsx", row.names=FALSE)
