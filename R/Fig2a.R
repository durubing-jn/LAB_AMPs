library(vegan)
library(ape)
library(phangorn)
# 输入数据
data <- read.table("input.txt",sep = "\t",comment.char = "",stringsAsFactors=F,header = T,row.names=1)
df_dist <- vegdist(data,method = 'bray')

# 使用hclust进行聚类
hc <- hclust(df_dist, "ave")

# 导出为树状图
pdf("cluster.pdf")
plot(hc, hang = -1)
dev.off()


df_tree <- as.phylo(hc)# 将聚类结果转成系统发育格式
write.tree(phy=df_tree, file="APMs_tree.nwk") # 输出newick格式文件
