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
tail(df_sentencing)
dim(df_sentencing)

# extract sentence into a column for days and months & total sentence length
sentencing_cleaned <- df_sentencing |>
  extract(sentence, into = c("years_sentence", "months_sentence",
                             "days_sentence"),
          regex = "(\\d+) Years (\\d+) Months (\\d+) Days",
          convert = TRUE) |>
  mutate(total_sentence = years_sentence + (months_sentence / 12) +
           (days_sentence / 365.25)) |>
  select(-days_sentence)
head(sentencing_cleaned)

sentencing_cleaned |> count(offense, sort = TRUE)
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
# other

table(sentencing_cleaned$class)

#sentence_temp <- sentencing_cleaned |>
 # group_by(id) |>
  #mutate(c_class = if_else(class == "X", "X", max(as.numeric(class))),
   #      c_count = sum(count),
    #     attempted = ifelse(offense %in% c("ATTEMPT", "ATT"), 1, 0),
     #    aggravated = ifelse(offense %in% c("AGG", "AGGRAVATED"), 1, 0),
      #   armed = ifelse(offense %in% c("ARMED", "ARM"), 1, 0),
       #  offense_category = case_when(
        #  offense %in% c("POSS AMT CON SUB", "SUB") ~ "illegal_contr_subst_poss",
         # offense %in% c("BURGLARY") ~ "BURGLARY",
          #TRUE ~ "OTHER"
            #))


# will write csv when confirmed
#write.csv(sentencing_cleaned, "CSV Files/sentencing_cleaned.csv",
#           row.names = F)
