#Loads specified libraries, installs and loads if not installed.

packages <- c("lubridate", "tidyverse")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}
remove(packages, pkg)


df <- read.csv("Documents/GitHub/project-5/CSV Files/person_1024.csv")

#Adding columns that will allow us to work with lubridate's functions in R 

df <- df %>% mutate(ymd_born = mdy(date_of_birth),
                    year_born = year(ymd_born),
                    month_born = month(ymd_born),
                    ymd_adm = mdy(admission_date),
                    year_adm = year(ymd_adm)) %>% 
  mutate(year_born = ifelse(year_born > 2002, year_born - 100, year_born),
         year_adm = ifelse(year_adm > 2018, year_adm - 100, year_adm))

#adm = admitted 
