#Loads specified libraries, installs and loads if not installed.

packages <- c("lubridate", "tidyverse")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}
remove(packages, pkg)

### sentencing.csv ID ROW NOT UNIQUE
# group by id
# Key: split sentencing "x Years", "y Months", "z Days"
# Drop days

df_sentencing <- read.csv("CSV Files/sentencing_1105.csv")
length(unique(df_sentencing$id))
head(df_sentencing)