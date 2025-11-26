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
# some X are because there are multiple tattoos separated by \;
# some X are multiple entries that failed to be separated by the semicolons

# replace all \; with , to avoid unnecessary splits
text <- readLines("CSV Files/marks.csv")
text <- gsub("\\\\;", ",", text)
writeLines(text, "CSV Files/marks_no_semicolon.csv")

df3 <- read.csv2("CSV Files/marks_no_semicolon.csv")
head(df3)
str(df3)
nrow(df3[is.na(df3$X),]) == nrow(df3)
# column X has no values; drop column X
df3 <- subset(df3, select = -X)

#TODO: pivot longer to create categories scars, tattoos, other
