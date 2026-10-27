usa_elapsed <- read.csv("01-elapsed_num.mle-USA/elapsed.csv")
uk_elapsed <- read.csv("02-elapsed_num.mle-UK/elapsed.csv")

usa_elapsed$minutes <- usa_elapsed$milliseconds / (1000 * 60)
uk_elapsed$minutes <- uk_elapsed$milliseconds / (1000 * 60)

tiff("Fig.S3.tiff", width = 12, height = 5, units = "in", res = 600)
par(mfrow = c(1, 2), mar = c(5, 5, 4, 2))

x1 <- usa_elapsed[usa_elapsed$version == "lemma", ]
x2 <- usa_elapsed[usa_elapsed$version == "no_lemma", ]
x1 <- x1[order(x1$epsilon), ]
x2 <- x2[order(x2$epsilon), ]

plot(x1$epsilon, x1$minutes, type = "b", pch = 1, lty = 1, lwd = 1, col = "black",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Running time (minutes)",
     main = "(a) USA-19 (w=1)",
     xaxt = "n",
     xlim = c(0, max(usa_elapsed$epsilon, na.rm = TRUE)),
     ylim = c(0, 0.18))

lines(x2$epsilon, x2$minutes, type = "b", pch = 2, lty = 2, lwd = 1, col = "black")
axis(1, at = seq(0, max(usa_elapsed$epsilon, na.rm = TRUE), by = 1))
legend("topleft", legend = c("No lemma", "With lemma"),
       pch = c(2, 1), lty = c(2, 1), lwd = 1, col = "black", bty = "n")

x1 <- uk_elapsed[uk_elapsed$version == "lemma", ]
x2 <- uk_elapsed[uk_elapsed$version == "no_lemma", ]
x1 <- x1[order(x1$epsilon), ]
x2 <- x2[order(x2$epsilon), ]

plot(x1$epsilon, x1$minutes, type = "b", pch = 1, lty = 1, lwd = 1, col = "black",
     xlab = expression("Genetic distance threshold (" * epsilon * ")"),
     ylab = "Running time (minutes)",
     main = "(b) UK-141 (w=1)",
     xaxt = "n",
     xlim = c(0, max(uk_elapsed$epsilon, na.rm = TRUE)),
     ylim = c(0, max(uk_elapsed$minutes, na.rm = TRUE)))

lines(x2$epsilon, x2$minutes, type = "b", pch = 2, lty = 2, lwd = 1, col = "black")
axis(1, at = seq(0, max(uk_elapsed$epsilon, na.rm = TRUE), by = 2))
legend("topleft", legend = c("No lemma", "With lemma"),
       pch = c(2, 1), lty = c(2, 1), lwd = 1, col = "black", bty = "n")

dev.off()
