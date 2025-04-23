# 读取数据
data <- read.table("input.txt", header = TRUE, sep = "\t")

# 查看前几行，确保正确读取
head(data)

# 导出为 PDF 文件
pdf("boxplot_output.pdf", width = 5, height = 6)

# 绘制箱线图
boxplot(data$`GCF.number`, data$`AMP.number`,
        names = c("GCF number", "AMP number"),
        col = c("skyblue", "salmon"),
        ylab = "Values")

# 为配对数据增加线条
for(i in 1:length(data$`GCF.number`)) {
  lines(c(1, 2), c(data$`GCF.number`[i], data$`AMP.number`[i]), col = "grey", lwd = 1)
}

# 关闭 PDF 输出设备
dev.off()

# 进行配对样本 t 检验
result <- t.test(data$`GCF.number`, data$`AMP.number`, paired = TRUE)

# 打印 t 检验结果
print(result)

# 计算效应大小 (Cohen's d)
# 计算配对差值
diffs <- data$`GCF.number` - data$`AMP.number`

# 计算配对差值的均值和标准差
mean_diff <- mean(diffs)
sd_diff <- sd(diffs)

# 计算 Cohen's d
cohen_d <- mean_diff / sd_diff

# 打印效应大小
cat("Cohen's d (Effect size):", cohen_d, "\n")

# 进行 FDR 校正
# 假设你有多个 t 检验的 P 值（这里仅为示例）
p_values <- c(result$p.value)  # 存储所有 t 检验的 P 值
adjusted_p_values <- p.adjust(p_values, method = "BH")  # Benjamini-Hochberg FDR 校正

# 打印 FDR 校正后的 P 值
cat("Adjusted P-values (FDR):", adjusted_p_values, "\n")

# 根据 FDR 校正后的 P 值评估显著性
if(adjusted_p_values < 0.05) {
  cat("The result is statistically significant based on FDR-adjusted P value.\n")
} else {
  cat("The result is not statistically significant based on FDR-adjusted P value.\n")
}
