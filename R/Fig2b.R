

library(ggplot2)
library(ggpubr)
#数据输入
data4 <- read.table("input.txt",sep = "\t",comment.char = "",stringsAsFactors=F,header = T)
p1 <- ggplot(data4,aes(x=genus,y=value,fill=genus)) +
  geom_boxplot(alpha=1,outlier.size=0,outlier.alpha=0)+
  geom_jitter(shape=16, position = position_jitter(0.2),colour = "black")+
  theme(panel.background = element_rect(fill="white", colour="black"),
        panel.grid = element_blank(), 
        axis.title = element_text(color="black",size=10),
        axis.ticks = element_line(color="black"), 
        axis.title.x = element_blank(),
        axis.title.y = element_text(colour="black",size=10,family="serif"),
        axis.text.x= element_text(angle=45,hjust=1,family="serif"),
        axis.text = element_text(colour="black",size=10,family="serif"),
        axis.line = element_line(colour = "black"))+
  guides(fill = "none")+
  ylab("Coefficient of Variation(%)")+
  scale_y_continuous(breaks=c(0,100,200,300,400,500))

p1
ggsave(p1,filename = "bioact-boxplot.pdf",width = 10,height = 5)




