usa <- read.csv("USA/mle_runtime_by_width_epsilon.csv")
uk <- read.csv("UK/mle_runtime_by_width_epsilon.csv")
usa$minutes <- usa$milliseconds/(1000*60)
uk$minutes <- uk$milliseconds/(1000*60)
widths <- c(1,2,4,8)
symbols <- 1:4
legend_text <- c(
  expression(w==1~(epsilon==1*", 2, 4, 8, 16")),
  expression(w==2~(epsilon==1*", 2, 4, 8, 16")),
  expression(w==4~(epsilon==1*", 2, 4, 8, 16")),
  expression(w==8~(epsilon==1*", 2, 4, 8, 16"))
)
usa_xmax <- ceiling(max(usa$num_mle)/1000)*1000
usa_ymax <- ceiling(max(usa$minutes)/0.1)*0.1
uk_xmax <- ceiling(max(uk$num_mle)/400000)*400000
uk_ymax <- ceiling(max(uk$minutes)/200)*200
tiff("Fig.S2.tiff", width=14, height=6, units="in", res=600)
par(mfrow=c(1,2),mar=c(5,6,3,2))
plot(usa$num_mle,usa$minutes,type="n",xaxt="n",yaxt="n",xaxs="i",yaxs="i",xlim=c(0,usa_xmax),ylim=c(0,usa_ymax),xlab="Number of MLEs",ylab="Running time (minutes)",main="(a) USA-19")
for(i in seq_along(widths)){
  x <- subset(usa,w==widths[i])
  points(x$num_mle,x$minutes,pch=symbols[i],cex=1.5,lwd=1.3)
}
axis(1,at=seq(0,usa_xmax,by=1000),labels=format(seq(0,usa_xmax,by=1000),big.mark=",",scientific=FALSE,trim=TRUE))
axis(2,at=pretty(c(0,usa_ymax)),labels=format(pretty(c(0,usa_ymax)),trim=TRUE),las=2)
legend("topleft",legend=legend_text,pch=symbols,pt.cex=1.5,pt.lwd=1.3,bty="n",cex=0.85)
box()
plot(uk$num_mle,uk$minutes,type="n",xaxt="n",yaxt="n",xaxs="i",yaxs="i",xlim=c(0,uk_xmax),ylim=c(0,uk_ymax),xlab="Number of MLEs",ylab="Running time (minutes)",main="(b) UK-141")
for(i in seq_along(widths)){
  x <- subset(uk,w==widths[i])
  points(x$num_mle,x$minutes,pch=symbols[i],cex=1.5,lwd=1.3)
}
axis(1,at=seq(0,uk_xmax,by=400000),labels=format(seq(0,uk_xmax,by=400000),big.mark=",",scientific=FALSE,trim=TRUE))
axis(2,at=seq(0,uk_ymax,by=200),labels=format(seq(0,uk_ymax,by=200),big.mark=",",scientific=FALSE,trim=TRUE),las=2)
legend("topleft",legend=legend_text,pch=symbols,pt.cex=1.5,pt.lwd=1.3,bty="n",cex=0.85)
box()
dev.off()
