#Loads specified libraries, installs and loads if not installed.
packages <- c("lubridate", "tidyverse")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}
remove(packages, pkg)

# read in person csv
df <- read.csv("CSV Files/person_1024.csv")


#Adding columns that will allow us to work with lubridate's functions in R 

df <- df %>% mutate(ymd_born = mdy(date_of_birth),
                    year_born = year(ymd_born),
                    month_born = month(ymd_born),
                    ymd_adm = mdy(admission_date),
                    year_adm = year(ymd_adm),
                    month_adm = month(ymd_adm)) %>% 
  mutate(year_born = ifelse(year_born >= 2002, year_born - 100, year_born),
         year_adm = ifelse(year_adm > 2018, year_adm - 100, year_adm))

#the step above returns a warning about NAs. Need to make a decision on what to do with those rows, work around or drop.

#adm = admitted

#Found some issues with formatting in the name column, seems like there's a space before every name.
#df2 <- df %>% filter(name == "JUAN") #returns 0 rows
#df2 <- df[df$name == "JUAN",] #returns the correct 227 rows

# strips whitespace before and after all string rows -- resolves whitespace issue for name
for (column in colnames(df)){
  if (class(df[,column]) == "character"){
    df[, column] = str_trim(df[, column])
  }
}

df_prep <- df %>% select(-projected_parole_date, -last_paroled_date, -projected_discharge_date, -parole_date,
                        -electronic_detention_date, -discharge_date, -location, -sex_offender_registry_required,
                        -ymd_born, -date_of_birth, -month_born, -ymd_adm, -admission_date)
#keep location ?

length(unique(df_prep$id)) == nrow(df_prep)

#excluding two weird cases I found in the data. must be data input issues
df_prep <- df_prep %>% filter(!id %in% c("X78949", "R56400") & year_adm > year_born)



#writing csv
write_csv(df_prep, "CSV Files/person_cleaned.csv")




