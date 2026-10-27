packages <- c("tidyverse", "magick")
to_install <- setdiff(packages, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install)
cat("R packages installed successfully.\n")
