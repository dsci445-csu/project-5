library(e1071)

set.seed(1)

#convert USDA.grade to factor
gradeDF$USDA.grade <- as.factor(gradeDF$USDA.grade)
predictorsDF <- gradeDF[,!(names(gradeDF) %in% c("USDA.grade"))] # dataframe without response

min_components <- 10 # it was found that components less than 15 did not perform optimially
max_components <- 80 #80
component_seq <- seq(min_components,max_components)

best_cost <- rep(NA, length(component_seq))
cv_mse <- rep(NA, length(component_seq))
best_model_list <- vector(mode="list", length=length(component_seq))  

min_cost <- .1
max_cost <- 10

abs_min_cost_lin <- min_cost
abs_max_cost_lin <- max_cost



for (i in seq(length(component_seq))) {
  
  num_components <- component_seq[i]
  costVec <- seq(from = min_cost, to = max_cost, length.out = 25)
  loadingDF <- pca_loadings[,1:num_components] # store the correct loadings DF
  
  scoresDF <- as.data.frame(as.matrix(predictorsDF) %*% as.matrix(loadingDF)) #compute the scores (z-values) for the given number of principal components
  scoresDF$USDA.grade <- gradeDF$USDA.grade
  
  TuneObj <- tune.svm(USDA.grade~ ., data = scoresDF, kernel = "linear", cost = costVec)
  
  bcost_temp <- TuneObj$best.parameters[1,1]
  
  temp_min_cost <- min_cost
  temp_max_cost <- max_cost
  
  rerun_bool <- FALSE
  
  if (bcost_temp == min_cost) {
    temp_min_cost <- min_cost/10
    temp_max_cost <- min_cost
    rerun_bool <- TRUE
  } else if (bcost_temp == max_cost) {
    temp_max_cost <- max_cost*10
    temp_min_cost <- max_cost
    rerun_bool <- TRUE
  }
  
  if (rerun_bool) {
    costVec <- seq(from = temp_min_cost, to = temp_max_cost, length.out = 20) 
    TuneObj <- tune.svm(USDA.grade~ ., data = scoresDF, kernel = "linear", cost = costVec)
  }
  
  abs_max_cost_lin <- max(abs_max_cost_lin, temp_max_cost)
  abs_min_cost_lin <- min(abs_min_cost_lin, temp_min_cost)
  
  best_cost[i] <- TuneObj$best.parameters[1,1]
  cv_mse[i] <- TuneObj$best.performance
  best_model_list[[i]] <- TuneObj$best.model
}

PrincipalComponent <- component_seq

linSVM_Results <- data.frame(PrincipalComponents_linSVM = PrincipalComponent, CV_MSE_linSVM = cv_mse, Best_Cost = best_cost)

#store the best model
linSVM_BestModel <- best_model_list[which.min(cv_mse)]
saveRDS(linSVM_BestModel, "SVM/BestSVMModels/BestLinModel.rds")

write.csv(linSVM_Results,"SVM/Results/LinSVM.csv", row.names = FALSE)