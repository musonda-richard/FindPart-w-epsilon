usa <- read.csv("01-USA/bic_by_width.csv", stringsAsFactors=FALSE)
uk <- read.csv("02-UK/bic_by_width.csv", stringsAsFactors=FALSE)
vec_w <- c(1, seq(10000, 200000, by=10000))

usa_inf <- usa[as.character(usa$w)=="Inf",]
usa <- usa[as.character(usa$w)!="Inf",]
usa$w <- as.numeric(usa$w)
usa$bic <- as.numeric(usa$bic)
usa <- usa[usa$w %in% vec_w,]
usa <- usa[is.finite(usa$w) & is.finite(usa$bic),]
usa <- usa[order(usa$w),]

uk$w <- as.numeric(uk$w)
uk$bic <- as.numeric(uk$bic)
uk <- uk[is.finite(uk$w) & is.finite(uk$bic),]
uk <- uk[order(uk$w),]

has_inf <- nrow(usa_inf)>0 && is.finite(as.numeric(usa_inf$bic[1]))
if(has_inf){
    inf_x <- max(usa$w)+50000
    usa_x <- c(usa$w, inf_x)
    usa_bic <- c(usa$bic, as.numeric(usa_inf$bic[1]))
}else{
    usa_x <- usa$w
    usa_bic <- usa$bic
}

tiff("Fig7.tiff", width=12, height=5, units="in", res=600)
par(mfrow=c(1,2), mar=c(4.5,5,3.5,1))

usa_mid <- mean(usa_bic, na.rm=TRUE)
usa_ylim <- c(floor(usa_mid)-1, ceiling(usa_mid)+1)
usa_ticks <- seq(usa_ylim[1], usa_ylim[2], by=1)
plot(usa_x, usa_bic, type="b", pch=1, xaxt="n", yaxt="n", xlab="Beam width (w)", ylab="BIC", main=expression(bold("(a) USA-19 (")*bold(epsilon==4)*bold(")")), ylim=usa_ylim, xlim=c(min(usa$w), if(has_inf) inf_x+10000 else max(usa$w)))
usa_axis <- seq(0, max(usa$w), by=50000)
usa_axis <- unique(c(1, usa_axis[usa_axis>0]))
axis(1, at=usa_axis, labels=format(usa_axis, big.mark=",", scientific=FALSE, trim=TRUE))
if(has_inf) axis(1, at=inf_x, labels=expression(infinity))
axis(2, at=usa_ticks, labels=format(usa_ticks, big.mark=",", scientific=FALSE, trim=TRUE))
box()

uk_ylim <- c(floor(min(uk$bic, na.rm=TRUE)), ceiling(max(uk$bic, na.rm=TRUE)))
uk_ticks <- seq(uk_ylim[1], uk_ylim[2], by=1)
plot(uk$w, uk$bic, type="b", pch=1, xaxt="n", yaxt="n", xlab="Beam width (w)", ylab="BIC", main=expression(bold("(b) UK-141 (")*bold(epsilon==7)*bold(")")), xlim=c(1,23), ylim=uk_ylim)
axis(1, at=1:23)
axis(2, at=uk_ticks, labels=format(uk_ticks, big.mark=",", scientific=FALSE, trim=TRUE))
box()

dev.off()
