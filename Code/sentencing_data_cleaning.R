#Loads specified libraries, installs and loads if not installed.

packages <- c("lubridate", "tidyverse", "stringr")

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
tail(df_sentencing)
dim(df_sentencing)

df_clean2 <- data.frame(df_sentencing)
non_numerical <- subset(df_clean2, !grepl("Year", sentence))
head(non_numerical[,c("id", "sentence")], 100)
# four exceptions to numerical sentences: LIFE, DEATH, SDP, blank
# convert life sentences to numerical, cap sentences to 100
df_clean2$life_sentence <- ifelse(str_detect(df_clean2$sentence, "LIFE"), TRUE, FALSE)
df_clean2[df_clean2$sentence == "LIFE",]$sentence <- "100 Years 0 Months 0 Days"
# replace sexually dangerous person sentence with 0 years
df_clean2[df_clean2$sentence == "SDP",]$sentence <- "0 Years 0 Months 0 Days"
# replace add categorical variable for death sentence
df_clean2$death_sentence <- ifelse(str_detect(df_clean2$sentence, "DEATH"), TRUE, FALSE)
# median time spent in prison preceding the carrying out of death sentence is 15 years
df_clean2[df_clean2$sentence == "DEATH",]$sentence <- "15 Years 0 Months 0 Days"
non_numerical <- subset(df_clean2, !grepl("Year", sentence))
head(non_numerical[,c("id", "sentence", "death_sentence", "life_sentence")], 100)


# extract sentence into a column for days and months & total sentence length
sentencing_clean <- df_clean2 |>
  extract(sentence, into = c("years_sentence", "months_sentence",
                             "days_sentence"),
          regex = "(\\d+) Years (\\d+) Months (\\d+) Days",
          convert = TRUE) |>
  mutate(years_sentence = replace_na(years_sentence, 0),
         months_sentence = replace_na(months_sentence, 0),
         days_sentence = replace_na(days_sentence, 0),
         total_sentence = years_sentence + (months_sentence / 12) +
           (days_sentence / 365.25)) |>
  select(-c(days_sentence, years_sentence, months_sentence))
head(sentencing_clean)

#group by date - HERES WHERE WE LEFT OFF
test <- sentencing_clean[0:100,] %>% 
  mutate()
test$ymd_custodydate = mdy(test$custody_date)

test[test$ymd_custodydate > as.Date("2020/01/01") & !is.na(test$ymd_custodydate), "ymd_custodydate"] <- 
  test[test$ymd_custodydate > as.Date("2020/01/01") & !is.na(test$ymd_custodydate), "ymd_custodydate"] - 36525
test2 <- test |> group_by(id, ymd_custodydate) |> summarise(sentence_by_date = sum(total_sentence)) 
test2
test3 <- test |> group_by(id) |> summarise(most_recent = max(ymd_custodydate))
test3
merge(test2, test3, on = id)
# %>% 
  # mutate(year_born = ifelse(year_born >= 2002, year_born - 100, year_born),
  #        year_adm = ifelse(year_adm > 2018, year_adm - 100, year_adm))

#%>% summary(charges = n())

#

sentencing_clean |> count(offense, sort = TRUE)
# OFFENSE CATEGORIES:
# attempted or committed?
# aggravated or not?
# armed or not?
# controlled subst poss w/out prescription
# burglary
# murder
# armed robbery
# theft (identity or property)
# battery
# sexual assault
# forgery
# kidnapping
# illegal firearm/weapon/handgun use or possession
# harassment
# bribery
# drug/meth manufacturing
# vehicular hijacking/theft
# DUI
# child porn
# obstructing justice
# home invasion
# other

class_severity_rank <- c("X", "M", "1", "2", "3", "4", "A", "B", "C", "U")

sentence_cleaner <- sentencing_clean |>
  mutate(c_class = factor(class, levels = class_severity_rank, ordered = TRUE),
         attempted = ifelse(str_detect(offense, "ATTEMPT|ATT"), 1, 0),
         aggravated = ifelse(str_detect(offense, "AGG|AGGRAVATED"), 1, 0),
         armed = ifelse(str_detect(offense, "ARMED|ARM"), 1, 0)) |>
  mutate(offense_category = case_when(
          str_detect(offense, "POSS AMT|SUB|NARC|POSSESSION OF METH") ~
            "ILL. CONTR. SUBST. POSS",
          str_detect(offense, "BURGLARY") ~ "BURGLARY",
          str_detect(offense, "MURDER|KILL") ~ "MURDER",
          str_detect(offense, "ROBBERY") ~ "ROBBERY",
          str_detect(offense, "THEFT") ~ "THEFT",
          str_detect(offense, "BATTERY|BTRY") ~ "BATTERY",
          str_detect(offense, "SEXUAL|SEX") ~ "SEXUAL OFFENSE",
          str_detect(offense, "FORGERY") ~ "FORGERY",
          #str_detect(offense, "HARASSMENT") ~ "HARASSMENT", 0
          str_detect(offense, "KIDNAPPING") ~ "KIDNAPPING",
          str_detect(offense, "FIREARM|WEAPON|HANDGUN") ~
            "ILLEGAL WEAPON USE/POSS",
          #str_detect(offense, "BRIBERY") ~ "BRIBERY", less than 50
          str_detect(offense, "MANUF|MANUFACTURE|MANU") ~
            "DRUG MANUFACTURE",
          str_detect(offense, "VEH|HIJACK|VEH THEFT") ~
            "VEHICULAR HIJACKING/THEFT",
          str_detect(offense, "DUI") ~ "DUI",
          str_detect(offense, "CHILD PORN|PORN") ~ "ILLEGAL/CHILD PORN",
          str_detect(offense, "OBSTR|OBSTRUCTING|JUSTICE") ~ 
            "OBSTRUCTING JUSTICE",
          str_detect(offense, "HOME INVASION") ~ "HOME INVASION",
          TRUE ~ "OTHER"))
table(sentence_cleaner$offense_category)

# group by id and summarize for one row per person
sentencing_cleanest <- sentence_cleaner |>
  group_by(id) |>
  filter(class == max(c_class)) |>
  summarize(total_counts = sum(count),
            custody_date = custody_date,
            total_sentence = sum(total_sentence, na.rm = T),
            class = c_class,
            offense_category = offense_category,
            attempted = attempted,
            aggravated = aggravated,
            armed = armed,
            illegal_contr_subst_poss = ifelse(offense_category ==
                                                "ILL. CONTR. SUBST. POSS", 1, 0),
            burglary = ifelse(offense_category == "BURGLARY", 1, 0),
            murder = ifelse(offense_category == "MURDER", 1, 0),
            robbery = ifelse(offense_category == "ROBBERY", 1, 0),
            theft = ifelse(offense_category == "THEFT", 1, 0),
            battery = ifelse(offense_category == "BATTERY", 1, 0),
            sexual_offense = ifelse(offense_category == "SEXUAL OFFENSE", 1, 0),
            forgery = ifelse(offense_category == "FORGERY", 1, 0),
            kidnapping = ifelse(offense_category == "KIDNAPPING", 1, 0),
            ill_weapon_use_or_poss = ifelse(offense_category ==
                                              "ILLEGAL WEAPON USE/POSS", 1, 0),
            drug_manufacture = ifelse(offense_category == "DRUG MANUFACTURE",
                                      1, 0),
            veh_hijacking_or_theft = ifelse(offense_category ==
                                              "VEHICULAR HIJACKING/THEFT", 1, 0),
            dui = ifelse(offense_category == "DUI", 1, 0),
            child_or_illegal_porn = ifelse(offense_category == "ILLEGAL/CHILD PORN",
                                           1, 0),
            obstructing_justice = ifelse(offense_category ==
                                           "OBSTRUCTING JUSTICE", 1, 0),
            home_invasion = ifelse(offense_category ==
                                     "HOME INVASION", 1, 0)) |>
  slice_sample(n = 1)  # if ties for max charge, choose randomly

head(sentencing_cleanest)
dim(sentencing_cleanest)
anyNA(sentencing_cleanest$total_sentence)



write.csv(sentencing_cleanest, "CSV Files/sentencing_cleaned.csv",
           row.names = F)
