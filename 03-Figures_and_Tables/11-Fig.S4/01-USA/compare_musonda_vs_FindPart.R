library(tidyverse)

musonda <- read.csv("musonda2026_USA19_relative_Re.csv") %>%
  rename(musonda2026_relative_Re = relative_Re)

findpart <- read.csv("../../09-Table1/best_estimates_with_rri.csv") %>%
  transmute(
    lineage = variant,
    findpart_relative_Re = rri
  )

cat("Musonda 2026 lineages:", n_distinct(musonda$lineage), "\n")
cat("FindPart lineages:", n_distinct(findpart$lineage), "\n")
cat("Common lineages:", length(intersect(musonda$lineage, findpart$lineage)), "\n")
cat("Only in Musonda 2026:", length(setdiff(musonda$lineage, findpart$lineage)), "\n")
cat("Only in FindPart:", length(setdiff(findpart$lineage, musonda$lineage)), "\n")

combined <- full_join(findpart, musonda, by = "lineage")

write.csv(
  combined,
  "USA19_Musonda2026_vs_FindPart_relative_Re.csv",
  row.names = FALSE
)

x <- combined %>% filter(lineage != "KP.3.1.1")

pearson_test <- cor.test(
  x$findpart_relative_Re,
  x$musonda2026_relative_Re,
  method = "pearson"
)

pearson_result <- data.frame(
  n = nrow(x),
  pearson_r = unname(pearson_test$estimate),
  p_value = pearson_test$p.value,
  ci_lower = pearson_test$conf.int[1],
  ci_upper = pearson_test$conf.int[2]
)

print(pearson_result)

write.csv(
  pearson_result,
  "USA19_Pearson_correlation.csv",
  row.names = FALSE
)
