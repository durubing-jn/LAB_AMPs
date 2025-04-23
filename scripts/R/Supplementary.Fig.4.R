library(ggplot2)

# 假设您的数据框名为 df
df <- read.table("input.txt", header = TRUE, sep = "\t")
# 绘制图形
ggplot(df, aes(y = species, x = mean)) +
  geom_point() +  # 添加点
  geom_errorbarh(aes(xmin = min, xmax = max), height = 0.2) +  # 添加水平误差棒
  labs(x = "Spacer per Mb", y = "Phylum") +  # 添加轴标签
  theme_minimal() +  # 使用简洁主题
  theme(
    axis.text.y = element_text(size = 10),  # 设置 Y 轴字体大小
    axis.text.x = element_text(size = 10)   # 设置 X 轴字体大小
  )


p <-ggplot(df, aes(x = species, y = mean)) +
  geom_pointrange(aes(ymin = min, ymax = max), 
                  shape = 21, size = 0.5, fill = "white", color = "black", linetype = "solid") +
  labs(x = "species", y = "Frequency") +  # 修改标签名称以反转 x 和 y 轴的标题
  theme_minimal() +  # 使用简洁主题
  theme(
    axis.text.x = element_text(size = 10, angle = 0, hjust = 1),  # 设置 X 轴字体大小和角度
    axis.text.y = element_text(size = 10),  # 设置 Y 轴字体大小
    axis.title.x = element_text(face = "bold", size = 12),  # X 轴标题样式
    axis.title.y = element_text(face = "bold", size = 12)  # Y 轴标题样式
  )

# 保存为 PDF 文件
ggsave("plot.pdf", plot = p, width = 8, height = 4, device = "pdf")
