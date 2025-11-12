#Loads specified libraries, installs and loads if not installed.
packages <- c("lubridate", "tidyverse")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}
remove(packages, pkg)

# read in marks csv
df <- read.csv("CSV Files/marks.csv")
