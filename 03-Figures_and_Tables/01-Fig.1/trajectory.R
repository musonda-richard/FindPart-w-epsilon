log_softmax <- function(x){
  m <- max(x)
  x - m - log(sum(exp(x - m)))
}

vec_t <- seq(0,100,by=1)
vec_pi <- c(0,1,1,2)

# parameters excluding baseline
a_param <- c(0.09,0.03)
b_param <- c(-2.3,-3.5,-2.0)

num_variants <- length(vec_pi)

q <- matrix(NA, length(vec_t), num_variants)

for(k in 1:length(vec_t)){
  t <- vec_t[k]
  vec_a <- c(0, a_param)
  vec_b <- c(0, b_param)
  
  vec_mu <- numeric(num_variants)
  
  for(i in 1:num_variants){
    vec_mu[i] <- vec_a[vec_pi[i] + 1] * t + vec_b[i]
  }
  
  q[k,] <- exp(log_softmax(vec_mu))
}

tiff("lineage_trajectories.tiff", width = 6, height = 5, units = "in", 
     res = 600, compression = "lzw")

matplot(vec_t, q, type="l", lwd=1, ylim=c(0,1), xlab="Time (days)", ylab="Relative frequency", col=c("#E64B35", "#4DBBD5", "#00A087", "#3C3C3C"), lty = c(1, 3, 2, 4)) 
legend_labels <- parse(text = paste0("italic(v)[", 0:(num_variants-1), "]"))
legend(60, 0.6,legend = legend_labels, col = c("#E64B35", "#4DBBD5", "#00A087", "#3C3C3C"), lwd = 1,lty = c(1, 3, 2, 4), bty = "n", cex = 1.0)

dev.off()
