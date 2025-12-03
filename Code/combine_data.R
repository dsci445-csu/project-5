marks <- read.csv("CSV Files/marks_unique_counts.csv")
people <- read.csv("CSV Files/person_cleaned.csv")
sentencing <- read.csv("CSV Files/sentencing_cleaned.csv")

merged_data <- merge(marks, people, on = "id")
merged_data <- merge(merged_data, sentencing, on = "id")

write.csv(merged_data, "CSV Files/merged_data.csv", row.names = F)
