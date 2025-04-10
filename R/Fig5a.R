
install.packages("remotes")
remotes::install_github("ricardo-bion/ggradar")

install_github("ricardo-bion/ggradar", INSTALL_opts = c("--with-keep.source", "--install-tests"))

devtools::install_github("ricardo-bion/ggradar", dependencies = TRUE)
library("ggradar")

devtools::install_github("xl0418/ggradar2",dependencies=TRUE)


rt=read.table("input.xls", sep="\t", header=T, check.names=F)    #读取输入文件
rt$ID <- factor(rt$ID,levels = rt$ID)
p<- ggradar(rt, 
        #设置grid标签环分割值（决定grid标签文字位置)
        #grid.max必须大于数据框最大值，grid.min控制最小环大小，太大图片不协调，
        #grid.mid设置为二者中间值，标签分布较协调
        grid.min = 0, grid.mid = 0.5, grid.max =1,
        
        #设置各层bar值，values.radar仅支持“内”、“中”，“外”三个数值，超过三个将只取前三
        values.radar = c("0", "50%", "100%"),
        
        gridline.min.colour = "blue",#轴值最小圈的颜色
        gridline.mid.colour="red",#轴值中位圈的颜色
        gridline.max.colour="black",#最大轴值圈的颜色
        
        #点的大小
        group.point.size=5,
        #线的粗细
        group.line.width=1.5,
        
        #axis为外圈文字，grid为圈内标签文字
        axis.label.size = 5, 
        grid.label.size = 6,
        
        
        #标题
        #plot.title = "基因表达量", legend.text.size = 14, 
        legend.title="Name",#图例的名字
        
        #设置不显示图例 legend.position ='none'
        legend.position = "right",   #图例的位置
        
        # 设置图片横向延伸空间，防止外圈文字显示不全
        plot.extent.x.sf = 1.2,
        
        #背景色，及透明度
        background.circle.colour = "white",
        background.circle.transparency = 0)
        
#输出图片
png(file="radar_multi.png", bg="transparent",width = 2500, height = 2000, res = 250, units = "px")
print(p)
dev.off()
pdf(file=paste("radar_multi.pdf",sep=""), height = 8, width = 9)
print(p)
dev.off()