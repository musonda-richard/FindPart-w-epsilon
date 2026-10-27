usa_mle <- read.csv("01-elapsed_num.mle-USA/num_mle.csv")
uk_mle <- read.csv("02-elapsed_num.mle-UK/num_mle.csv")

tiff("Fig.4.tiff", width = 12, height = 5, units = "in", res = 600)
par(mfrow = c(1, 2), mar = c(5, 5, 4, 2))

x1 <- usa_mle[usa_mle$version == "lemma", ]
x2 <- usa_mle[usa_mle$version == "no_lemma", ]
x1 <- x1[order(x1$epsilon), ]
x2 <- x2[order(x2$epsilon), ]
yticks <- pretty(c(0, max(usa_mle$num_mle, na.rm = TRUE)))

plot(x1$epsilon, x1$num_mle, type = "b", pch = 1, lty = 1, lwd = 1, col = "black",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Number of MLEs",
     main = "(a) USA-19 (w=1)",
     xaxt = "n", yaxt = "n",
     xlim = c(0, max(usa_mle$epsilon, na.rm = TRUE)),
     ylim = c(0, max(usa_mle$num_mle, na.rm = TRUE)))

lines(x2$epsilon, x2$num_mle, type = "b", pch = 2, lty = 2, lwd = 1, col = "black")
axis(1, at = seq(0, max(usa_mle$epsilon, na.rm = TRUE), by = 1))
axis(2, at = yticks, labels = format(yticks, big.mark = ",", scientific = FALSE, trim = TRUE))
legend("topleft", legend = c("No lemma", "With lemma"),
       pch = c(2, 1), lty = c(2, 1), lwd = 1, col = "black", bty = "n")

x1 <- uk_mle[uk_mle$version == "lemma", ]
x2 <- uk_mle[uk_mle$version == "no_lemma", ]
x1 <- x1[order(x1$epsilon), ]
x2 <- x2[order(x2$epsilon), ]
yticks <- pretty(c(0, max(uk_mle$num_mle, na.rm = TRUE)))

plot(x1$epsilon, x1$num_mle, type = "b", pch = 1, lty = 1, lwd = 1, col = "black",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Number of MLEs",
     main = "(b) UK-141 (w=1)",
     xaxt = "n", yaxt = "n",
     xlim = c(0, max(uk_mle$epsilon, na.rm = TRUE)),
     ylim = c(0, max(uk_mle$num_mle, na.rm = TRUE)))

lines(x2$epsilon, x2$num_mle, type = "b", pch = 2, lty = 2, lwd = 1, col = "black")
axis(1, at = seq(0, max(uk_mle$epsilon, na.rm = TRUE), by = 2))
axis(2, at = yticks, labels = format(yticks, big.mark = ",", scientific = FALSE, trim = TRUE))
legend("topleft", legend = c("No lemma", "With lemma"),
       pch = c(2, 1), lty = c(2, 1), lwd = 1, col = "black", bty = "n")

dev.off()
