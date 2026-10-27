usa_file <- "01-USA-pairwise-distances/pairwise_gen_distances.csv"
uk_file <- "02-UK-pairwise-distances/pairwise_gen_distances.csv"
df_usa <- read.csv(usa_file)
df_uk <- read.csv(uk_file)
vec_usa <- df_usa$distance
vec_uk <- df_uk$distance
x_min <- min(c(vec_usa, vec_uk))
x_max <- max(c(vec_usa, vec_uk))
breaks_common <- seq(x_min - 0.5, x_max + 0.5, by = 1)

plot_hist_panel <- function(vec_dist, main_title) {
    hist(vec_dist, breaks = breaks_common, probability = FALSE, xlab = "Pairwise genetic distance", ylab = "Number of lineage pairs", xaxt = "n", right = FALSE, main = main_title)
    axis(1, at = x_min:x_max)
    box(lwd = 1.5)
}

tiff("Fig.S1.tiff", width = 10, height = 5, units = "in", res = 600, compression = "lzw")
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
plot_hist_panel(vec_usa, "(a) USA–19")
plot_hist_panel(vec_uk, "(b) UK–141")
dev.off()
