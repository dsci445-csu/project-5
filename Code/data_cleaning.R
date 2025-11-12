#Loads specified libraries, installs and loads if not installed.

packages <- c("lubridate", "tidyverse")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}
remove(packages, pkg)


# the above line of code does not work for me -- 
# if everyone is cloning from github would the following line work instead? - Hope
df <- read.csv("CSV Files/person_1024.csv")

#Adding columns that will allow us to work with lubridate's functions in R 

df <- df %>% mutate(ymd_born = mdy(date_of_birth),
                    year_born = year(ymd_born),
                    month_born = month(ymd_born),
                    ymd_adm = mdy(admission_date),
                    year_adm = year(ymd_adm)) %>% 
  mutate(year_born = ifelse(year_born > 2002, year_born - 100, year_born),
         year_adm = ifelse(year_adm > 2018, year_adm - 100, year_adm))

#the step above returns a warning about NAs. Need to make a decision on what to do with those rows, work around or drop.

#adm = admitted

#Found some issues with formatting in the name column, seems like there's a space before every name.
#df2 <- df %>% filter(name == "JUAN") #returns 0 rows
#df2 <- df[df$name == " JUAN",] #returns the correct 227 rows

# strips whitespace before and after all string rows -- resolves whitespace issue for name
for (column in colnames(df)){
  if (class(df[,column]) == "character"){
    df[, column] = str_trim(df[, column])
  }
}




