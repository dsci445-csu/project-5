# Get Data

REIMS <- read.csv("REIMS machine learning class.csv")

dropBase <- c("SampleID", "Cx", "GS_1", "GS_2", "UNIQ_ID", "Ten42", "Ten56", "Ten70")
responseVars <- c("USDA.grade", "Ten3", "Ten14","Ten28")

# Define the associated dataframes for each analysis. Response variable is column 1, predictors are the remaining columns
gradeDF <- REIMS[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("USDA.grade"))))]

#Creating training and test subsets for regressions
set.seed(1)
dpart <- createDataPartition(REIMS$USDA.grade, p = 0.6, list = F)
train<- REIMS[dpart, ]
test<- REIMS[-dpart, ]

ten3DF_train<- na.omit(train[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten3"))))])
ten3DF_test<-na.omit(test[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten3"))))])
ten14DF_train<-na.omit(train[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten14"))))])
ten14DF_test<-na.omit(test[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten14"))))])
ten28DF_train<-na.omit(train[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten28"))))])
ten28DF_test<-na.omit(test[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten28"))))])

# Completed datasets for regressions
ten3DF <- na.omit(REIMS[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten3"))))])
ten14DF <- na.omit(REIMS[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten14"))))])
ten28DF <- na.omit(REIMS[,!(names(REIMS) %in% union(dropBase,setdiff(responseVars, c("Ten28"))))])
