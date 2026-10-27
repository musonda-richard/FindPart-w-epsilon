usa <- read.csv("01-USA/mle_by_width.csv", stringsAsFactors=FALSE)
uk <- read.csv("02-UK/mle_by_width.csv", stringsAsFactors=FALSE)
vec_w <- c(1, seq(10000, 200000, by=10000))

usa_inf <- usa[as.character(usa$w)=="Inf",]
usa <- usa[as.character(usa$w)!="Inf",]
usa$w <- as.numeric(usa$w)
usa$num_mle <- as.numeric(usa$num_mle)
usa <- usa[usa$w %in% vec_w,]
usa <- usa[is.finite(usa$w) & is.finite(usa$num_mle),]
usa <- usa[order(usa$w),]

uk$w <- as.numeric(uk$w)
uk$num_mle <- as.numeric(uk$num_mle)
uk <- uk[is.finite(uk$w) & is.finite(uk$num_mle),]
uk <- uk[order(uk$w),]

has_inf <- nrow(usa_inf)>0 && is.finite(as.numeric(usa_inf$num_mle[1]))
if(has_inf){
    inf_x <- max(usa$w)+50000
    usa_x <- c(usa$w, inf_x)
    usa_mle <- c(usa$num_mle, as.numeric(usa_inf$num_mle[1]))
}else{
    usa_x <- usa$w
    usa_mle <- usa$num_mle
}

tiff("Fig6.tiff", width=12, height=5, units="in", res=600)
par(mfrow=c(1,2), mar=c(4.5,5,3.5,1))

usa_ylim <- c(0, ceiling(max(usa_mle)/100000)*100000)
plot(usa_x, usa_mle, type="b", pch=1, xaxt="n", yaxt="n", xlab="Beam width (w)", ylab="Number of MLEs", main=expression(bold("(a) USA-19 (")*bold(epsilon==4)*bold(")")), ylim=usa_ylim, xlim=c(min(usa$w), if(has_inf) inf_x+10000 else max(usa$w)))
usa_axis <- seq(0, max(usa$w), by=50000)
usa_axis <- unique(c(1, usa_axis[usa_axis>0]))
axis(1, at=usa_axis, labels=format(usa_axis, big.mark=",", scientific=FALSE, trim=TRUE))
if(has_inf) axis(1, at=inf_x, labels=expression(infinity))
usa_y_ticks <- pretty(c(0, max(usa_mle)))
axis(2, at=usa_y_ticks, labels=format(usa_y_ticks, big.mark=",", scientific=FALSE, trim=TRUE))
box()

uk_ylim <- c(0, ceiling(max(uk$num_mle)/100000)*100000)
plot(uk$w, uk$num_mle, type="b", pch=1, xaxt="n", yaxt="n", xlab="Beam width (w)", ylab="Number of MLEs", main=expression(bold("(b) UK-141 (")*bold(epsilon==7)*bold(")")), xlim=c(1,23), ylim=uk_ylim)
axis(1, at=1:23)
uk_y_ticks <- pretty(c(0, max(uk$num_mle)))
axis(2, at=uk_y_ticks, labels=format(uk_y_ticks, big.mark=",", scientific=FALSE, trim=TRUE))
box()

dev.off()
