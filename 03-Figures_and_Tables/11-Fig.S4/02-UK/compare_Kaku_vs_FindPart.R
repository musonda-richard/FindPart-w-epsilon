library(tidyverse)

kaku <- read.csv("kaku_2024_UK141_relative_Re.csv") %>%
  rename(kaku_relative_Re = relative_Re)

findpart <- read.csv("../../10-Table2/best_estimates_with_rri.csv") %>%
  transmute(
    lineage = variant,
    findpart_relative_Re = rri
  )

cat("Kaku lineages:", n_distinct(kaku$lineage), "\n")
cat("FindPart lineages:", n_distinct(findpart$lineage), "\n")
cat("Common lineages:", length(intersect(kaku$lineage, findpart$lineage)), "\n")
cat("Only in Kaku:", length(setdiff(kaku$lineage, findpart$lineage)), "\n")
cat("Only in FindPart:", length(setdiff(findpart$lineage, kaku$lineage)), "\n")

combined <- full_join(findpart, kaku, by = "lineage")

write.csv(
  combined,
  "UK141_Kaku_vs_FindPart_relative_Re.csv",
  row.names = FALSE
)

x <- combined %>% filter(lineage != "EG.5.1")

pearson_test <- cor.test(
  x$findpart_relative_Re,
  x$kaku_relative_Re,
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
  "UK141_Pearson_correlation.csv",
  row.names = FALSE
)
