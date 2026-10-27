library(dplyr)

df_rri <- read.csv("best_estimates_with_rri.csv")
df_blocks <- read.csv("best_blocks.csv")
dist_file <- Sys.getenv("PANGOLIN_DISTANCES", unset = "pangolin_distances.csv")
df_dist <- read.csv(dist_file)

max_dist <- df_blocks %>%
  group_by(block) %>%
  summarise(variants = list(variant), .groups = "drop") %>%
  rowwise() %>%
  mutate(max_distance = {
    vv <- variants
    if (length(vv) == 1) {
      0
    } else {
      dd <- df_dist %>% filter(var1 %in% vv & var2 %in% vv)
      max(dd$distance)
    }
  }) %>%
  ungroup() %>%
  select(block, max_distance)

df_table <- df_blocks %>%
  left_join(df_rri %>% select(variant, rri, rri_lb, rri_ub), by = "variant") %>%
  mutate(
    rri = round(rri, 3),
    rri_lb = round(rri_lb, 3),
    rri_ub = round(rri_ub, 3),
    block_label = paste0("(Block ", block, ")")
  ) %>%
  group_by(block, block_label, rri, rri_lb, rri_ub) %>%
  summarise(Lineage = paste(variant, collapse = ", "), .groups = "drop") %>%
  left_join(max_dist, by = "block") %>%
  arrange(desc(rri)) %>%
  mutate(
    `95% CI` = paste0(sprintf("%.3f", rri_lb), "–", sprintf("%.3f", rri_ub)),
    `R_RI (rho)` = sprintf("%.3f", rri)
  ) %>%
  select(Lineage, `Block identifier` = block_label, `Maximum distance` = max_distance,`R_RI (rho)`, `95% CI`)

write.csv(df_table, "Table2.csv", row.names = FALSE)
