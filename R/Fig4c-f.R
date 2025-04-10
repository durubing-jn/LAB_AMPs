args<-commandArgs(T)
alpha_index= "input.xls"
group_col= "group.color.list"
library(ggplot2)
library(ggsignif)
x2<-read.table(group_col,sep="\t",head=F,comment.char = "",stringsAsFactors=F)
names(x2)=c("sample.id","Group.name","colour")
xx<-read.table(alpha_index,head=T,sep="\t",comment='')
mydata = merge(x2, xx, by.y= "sample.id")
rownames(mydata) = mydata$sample.id
#mydata = data[,-1]
write.table(mydata,"data.xls",sep = '\t',quote = FALSE,col.names = NA)
a=unique(mydata$Group.name)

if( length(a) > 60){
  g<-c(mydata$colour[-1],paste(mydata$colour[length(mydata$colour)],""))
  b = mydata$colour[ mydata$colour != g]
}else{b=unique(mydata$colour)}

mydata$Group.name=factor(mydata$Group.name,levels=as.vector(a))

cnames<-colnames(mydata)
sigFunc = function(x){
  if(x < 0.001){"***"} 
  else if(x < 0.01){"**"}
  else if(x < 0.05){"*"}
  else{NA}
}
color <- x2$colour[match(c("LAB","Archaic_animal","human","Microbes","public_data"), x2$Group.name)]


for(i in 4:length(cnames)){
  g <- levels(mydata$Group.name)
  compared.group <- list(c("LAB", "Archaic_animal"), 
                         c("LAB", "Microbes"), 
                         c("LAB", "human"), 
                         c("LAB", "public_data"))
  
  p <- ggplot(data=mydata, aes(x=Group.name, y=mydata[,i]), fill=unique(Group.name)) + 
    geom_boxplot(fill=color, alpha=0.3, outlier.shape = NA, size=0.3) +  # 忽略异常值
    labs(x="", y=cnames[i]) +
    scale_x_discrete(limits = c("LAB", "Archaic_animal", "human","Microbes" , "public_data")) +
    theme(panel.background = element_rect(fill="white", colour="black"),
          panel.grid = element_blank(), 
          axis.title = element_text(color="black", size=14),
          axis.ticks = element_line(color="black"), 
          axis.title.x = element_text(colour="black", size=14),
          axis.title.y = element_text(colour="black", size=22),
          axis.text.x = element_text(angle=45, hjust=1),
          axis.text = element_text(colour="black", size=14),
          axis.line = element_line(colour = "black"),
          legend.position ="none")+
    geom_signif(test="wilcox.test", comparisons = compared.group, step_increase = 0.1, map_signif_level = sigFunc, margin_top = 0.05)
  
  png(file=paste(cnames[i],'.png', sep=""), res=72*3, width=200*3, height=300*3)
  ggsave(p, file=paste(cnames[i], "boxplot.pdf", sep="-"), width=3, height=4, limitsize=F)
  print(p)
  dev.off()
}

