marks <- read.csv("CSV Files/marks_unique_counts.csv")
people <- read.csv("CSV Files/person_cleaned.csv")
sentencing <- read.csv("CSV Files/sentencing_cleaned.csv")

merged_data <- merge(marks, people, on = "id")
merged_data <- merge(merged_data, sentencing, on = "id")

merged_data_end <- merged_data %>% mutate(appx_age = year_adm - year_born) %>% 
  select(-offender_status, -year_born)

write.csv(merged_data_end, "CSV Files/merged_data.csv", row.names = F)
