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
remove(non_numerical)

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
# convert dates from character to Date type
test <- sentencing_clean |>
  mutate(ymd_custodydate = mdy(custody_date)) 
# convert 2060s dates into 1960s dates
test[test$ymd_custodydate > as.Date("2020/01/01") & !is.na(test$ymd_custodydate), "ymd_custodydate"] <- 
  test[test$ymd_custodydate > as.Date("2020/01/01") & !is.na(test$ymd_custodydate), "ymd_custodydate"] - 36525
# get sentence lengths for each custody date
test2 <- test |> group_by(id, ymd_custodydate) |> summarise(sentence_by_date = sum(total_sentence)) 
# get most recent custody date
test3 <- test |> group_by(id) |> summarise(most_recent_custody_date = max(ymd_custodydate))
# combine
test4 <- merge(test2, test3, on = id)

# split into most recent custody date and prior custody dates
most_recent <- test4[test4$ymd_custodydate == test4$most_recent, ]
prior <- test4[test4$ymd_custodydate != test4$most_recent, ]
# assume that if an individual has an NA custody date, that is their most recent
prior <- drop_na(prior)
# combine all prior sentence lengths into one
prior2 <- prior |> group_by(id) |> 
  summarise(time_sentenced_prior = sum(sentence_by_date))
colnames(most_recent)[colnames(most_recent) == 'sentence_by_date'] <- 'current_sentence'
# new data set has id, current sentence, most recent custody date, and 
# time sentenced prior to most recent custody date
sentence_lengths <- merge(most_recent, prior2, on = id, all.x = TRUE) 
sentence_lengths$time_sentenced_prior <- replace_na(sentence_lengths$time_sentenced_prior, 0)

mr_offense <- merge(most_recent, test, by = c("id", "ymd_custodydate"))

life_death <- test |> group_by(id) |> summarise(life_sentence = any(life_sentence),
                                  death_sentence = any(death_sentence))
sl2 <- merge(sentence_lengths, life_death)
# cap current sentences to 100 years
cap_current <- which(sl2$current_sentence > 100)
sl2[cap_current, "current_sentence"] <- 100
sl2[cap_current, "life_sentence"] <- T
# cap prior sentences to 100 years
cap_prior <- which(sl2$time_sentenced_prior > 100)
sl2[cap_prior, "time_sentenced_prior"] <- 100
sl2[cap_prior, "life_sentence"] <- T

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

sentence_cleaner <- mr_offense |>
  mutate(c_class = factor(class, levels = class_severity_rank, ordered = TRUE),
         attempted = ifelse(str_detect(offense, "ATTEMPT|ATT"), TRUE, FALSE),
         aggravated = ifelse(str_detect(offense, "AGG|AGGRAVATED"), TRUE, FALSE),
         armed = ifelse(str_detect(offense, "ARMED|ARM"), TRUE, FALSE)) |>
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
          str_detect(offense, "KIDNAPPING") ~ "KIDNAPPING",
          str_detect(offense, "FIREARM|WEAPON|HANDGUN") ~
            "ILLEGAL WEAPON USE/POSS",
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
            class = c_class,
            offense_category = offense_category,
            attempted = any(attempted),
            aggravated = any(aggravated),
            armed = any(armed),
            ) |>
  slice_sample(n = 1)  # if ties for max charge, choose randomly

head(sentencing_cleanest)
dim(sentencing_cleanest)

final_dataset <- merge(sentencing_cleanest, sl2, by = c("id"))
final_dataset <- final_dataset[,!names(final_dataset) %in% c("custody_date", "ymd_custodydate")]


length(unique(df_sentencing$id))
nrow(final_dataset)

write.csv(final_dataset, "CSV Files/sentencing_cleaned.csv",
           row.names = F)

confirm <- read.csv("CSV Files/sentencing_cleaned.csv")
head(confirm)
