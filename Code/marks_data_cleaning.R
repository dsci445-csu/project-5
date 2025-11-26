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
df <- read.csv("CSV Files/marks.csv", header = F)
str(df)
head(df)

#previewing marks.csv reveals columns may be separated by semicolons rather than commas
df2 <- read.csv2("CSV Files/marks.csv")
str(df2)
head(df2)
head(df2[df2$X != "",])
# some X are because there are multiple tatoos separated by semicolons
# some X are multiple entries that failed to be separated by the semicolons

#TODO: pivot longer to create categories scars, tattoos, other
