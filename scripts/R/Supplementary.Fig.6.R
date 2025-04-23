##############################
# 简书号：生信狗的修炼秘籍
# https://www.jianshu.com/p/e90aca76b23f
##############################

#install.packages("plyr")
#install.packages("ggpubr")


#引用包
library(plyr)
library(ggpubr)

#setwd("D:\\biowolf\\bioR\\06.boxplotSort") 

rt=read.table("input.txt", sep="\t", header=T, check.names=F)    #读取输入文件
x=colnames(rt)[2]
y=colnames(rt)[3]
colnames(rt)=c("id","Type","expression")

#定义输出图片的排序方式
med=ddply(rt,"Type",summarise,med=median(expression))
rt$Type=factor(rt$Type, levels=med[order(med[,"med"],decreasing = T),"Type"])

#绘制
p=ggboxplot(rt, x="Type", y="expression", color = "Type",
       palette = "npg",                     # palette可以按照期刊选择相应的配色，如"npg","jco"等
       ylab=y,
       xlab=x,
       size = 0.9,
       #add = "jitter",                    #绘制每个样品的散点
       legend = "right")
p= p+theme(axis.text.x = element_text(size =12,face="bold",color = "black"))
p= p+theme(axis.text.y = element_text(size =12,face="bold",color = "black")) # Y轴坐标字体的大小和颜色
p= p+theme(axis.title.x=element_text( face="bold", size=15,color = "black")) 
p= p+theme(axis.title.y=element_text(angle=90, face="bold", size=15,color = "black"))  # Y轴标题字体的大小和颜色
p= p+guides(fill=guide_legend())+theme(legend.text = element_text(size=10)) # legend 设置

p+ rotate_x_text(60) #倾斜角度
png(file="boxplot.png", bg="transparent",width = 4000, height = 3500, res = 500, units = "px")
print(p)
dev.off()
pdf(file=paste("boxplot.pdf",sep=""), height = 5, width = 10)
print(p)
dev.off()

