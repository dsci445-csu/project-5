library(caret)

set.seed(1)

# Importing data matrix
REIMS <- read.csv("REIMS machine learning class.csv")
dat <- REIMS[-c(1:4)]
dat<-dat[-c(2:8)]
# Calculate correlation matrix
correlationMatrix <- cor(dat)
# Find attributes that are highly corrected (0.9)
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff = 0.90)
length(highlyCorrelated)

# Discharge predictors that are highly correlated.
REIMS1 <- data.frame(USDA.grade = REIMS[,6],dat[,-highlyCorrelated])
REIMS1<-REIMS1[-2]
write.csv(REIMS1, file = "REIMS_nonredunt.csv")
DIM<-dim(REIMS1)
subset<- seq(1,DIM[2],5)

set.seed(1)
REIMS1$USDA.grade<-as.factor(REIMS1$USDA.grade)
#Define the control using a random forest selection function
control <- rfeControl(functions=rfFuncs, method="cv", number = 5)
dim(REIMS1)
#Run the RFE algorithm
resultsDataFS <- rfe(REIMS1[,-1], REIMS1[,1], sizes= subset, rfeControl=control)
#Creating new data set
FS_Data1 <- subset(REIMS1, select=predictors(resultsDataFS))
FS_REIMS <- data.frame(USDA.grade= REIMS1[,1],FS_Data1)
# save reduced data set
write.csv(FS_REIMS, file = "REIMS_FS_data.csv")

