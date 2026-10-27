rank_df <- read.csv("rank_by_epsilon.csv")
ll_df <- read.csv("loglik_by_epsilon.csv")
bic_df <- read.csv("BIC_by_epsilon_USA_UK.csv")

rank_usa <- subset(rank_df, dataset == "USA")
rank_uk <- subset(rank_df, dataset == "UK")
ll_usa <- subset(ll_df, dataset == "USA")
ll_uk <- subset(ll_df, dataset == "UK")
bic_usa <- subset(bic_df, dataset == "USA")
bic_uk <- subset(bic_df, dataset == "UK")

tiff("Fig.5.tiff", width = 12, height = 16, units = "in", res = 600)
par(mfrow = c(3, 2), mar = c(5, 5, 3, 1))

plot(bic_usa$epsilon, bic_usa$BIC,
     type = "b", pch = 19, lty = 1, xaxt = "n",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "BIC",
     main = "(a) USA-19: BIC (w=1)")
axis(1, at = bic_usa$epsilon)

plot(bic_uk$epsilon, bic_uk$BIC,
     type = "b", pch = 19, lty = 1, xaxt = "n",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "BIC",
     main = "(b) UK-141: BIC (w=1)")
axis(1, at = bic_uk$epsilon)

plot(ll_usa$epsilon, ll_usa$loglik,
     type = "b", pch = 19, lty = 1, xaxt = "n",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Maximum log-likelihood",
     main = "(c) USA-19: Maximum log-likelihood (w=1)")
axis(1, at = ll_usa$epsilon)

plot(ll_uk$epsilon, ll_uk$loglik,
     type = "b", pch = 19, lty = 1, xaxt = "n",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Maximum log-likelihood",
     main = "(d) UK-141: Maximum log-likelihood (w=1)")
axis(1, at = ll_uk$epsilon)

plot(rank_usa$epsilon, rank_usa$rank,
     type = "b", pch = 19, lty = 1,
     xaxt = "n", yaxt = "n", yaxs = "i",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Rank",
     main = "(e) USA-19: Rank (w=1)",
     ylim = c(0.5, 20))
axis(1, at = rank_usa$epsilon)
axis(2, at = c(1, 5, 10, 15, 19))

plot(rank_uk$epsilon, rank_uk$rank,
     type = "b", pch = 19, lty = 1,
     xaxt = "n", yaxt = "n", yaxs = "i",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Rank",
     main = "(f) UK-141: Rank (w=1)",
     ylim = c(0.5, 145))
axis(1, at = rank_uk$epsilon)
axis(2, at = c(1, 20, 40, 60, 80, 100, 120, 140))

dev.off()
