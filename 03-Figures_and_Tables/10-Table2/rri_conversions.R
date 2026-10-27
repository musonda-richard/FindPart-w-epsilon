generation_time <- as.numeric(Sys.getenv("GENERATION_TIME", unset = "2.1"))

if (!is.finite(generation_time) || generation_time <= 0) {
  stop("GENERATION_TIME must be a positive number")
}

df <- read.csv("best_estimates.csv")

df$rri <- exp(df$b1 * generation_time)
df$rri_lb <- exp(df$b1_lb * generation_time)
df$rri_ub <- exp(df$b1_ub * generation_time)

write.csv(df, "best_estimates_with_rri.csv", row.names = FALSE)
