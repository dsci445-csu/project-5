set.seed(1)

#convert USDA.grade to factor
gradeDF$USDA.grade <- as.factor(gradeDF$USDA.grade)
predictorsDF <- gradeDF[,!(names(gradeDF) %in% c("USDA.grade"))] # dataframe without response

min_components <- 5  # 5 it was found that components less than 15 did not perform optimially
max_components <- 60 # 50
component_seq <- seq(min_components,max_components)

best_cost <- rep(NA, length(component_seq))
best_gamma <- rep(NA, length(component_seq))
cv_mse <- rep(NA, length(component_seq))
best_model_list <- vector(mode="list", length=length(component_seq)) 

min_cost <- .01
max_cost <- 100

min_gamma <- .01
max_gamma <- 10


abs_min_cost <- min_cost
abs_max_cost <- max_cost
abs_min_gamma <- min_gamma
abs_max_gamma <- max_gamma



for (i in seq(length(component_seq))) {
  
  costVec <- seq(from = min_cost, to = max_cost, length.out = 10)
  gammaVec <- seq(from = min_gamma, to = max_gamma, length.out = 10)
  
  num_components <- component_seq[i]
  
  loadingDF <- pca_loadings[,1:num_components] # store the correct loadings DF
  
  scoresDF <- as.data.frame(as.matrix(predictorsDF) %*% as.matrix(loadingDF)) #compute the scores (z-values) for the given number of principal components
  scoresDF$USDA.grade <- gradeDF$USDA.grade
  
  TuneObj <- tune.svm(USDA.grade~ ., data = scoresDF, kernel = "radial", cost = costVec, gamma = gammaVec)
  
  rerun_bool <- FALSE
  
  bcost_temp <- TuneObj$best.parameters[1,2]
  bgamma_temp <- TuneObj$best.parameters[1,1]
  
  temp_min_cost <- min_cost
  temp_max_cost <- max_cost
  temp_min_gamma <- min_gamma
  temp_max_gamma <- max_gamma
  
  if (bcost_temp == min_cost) {
    temp_min_cost <- min_cost/10^2
    temp_max_cost <- min_cost
    rerun_bool <- TRUE
  } else if (bcost_temp == max_cost) {
    temp_min_cost <- max_cost
    temp_max_cost <- max_cost*10^2
    rerun_bool <- TRUE
  }
  
  if (bgamma_temp == min_gamma) {
    temp_min_gamma <- min_gamma/10^2
    temp_max_gamma <- min_gamma
    rerun_bool <- TRUE
  } else if (bgamma_temp == max_gamma) {
    temp_min_gamma <- max_gamma
    temp_max_gamma <- max_gamma*10^2
    rerun_bool <- TRUE
  }
  
  if (rerun_bool) {
    costVec <- seq(from = temp_min_cost, to = temp_max_cost, length.out = 10)
    gammaVec <- seq(from = temp_min_gamma, to = temp_max_gamma, length.out = 10)
    TuneObj <- tune.svm(USDA.grade~ ., data = scoresDF, kernel = "radial", cost = costVec, gamma = gammaVec)
  }
  
  best_cost[i] <- TuneObj$best.parameters[1,2]
  best_gamma[i] <- TuneObj$best.parameters[1,1]
  cv_mse[i] <- TuneObj$best.performance
  best_model_list[[i]] <- TuneObj$best.model
  
  abs_min_cost <- min(c(abs_min_cost, temp_min_cost)) 
  abs_max_cost <- max(c(abs_max_cost, temp_max_cost))
  abs_min_gamma <- min(c(abs_min_gamma, temp_min_gamma))
  abs_max_gamma <- max(c(abs_max_gamma, temp_max_gamma))
}

PrincipalComponent <- component_seq

radSVMTuning_Results <- data.frame(PrincipalComponents_radSVM = PrincipalComponent, CV_MSE_radSVM = cv_mse, Best_Cost_radSVM = best_cost, Best_Gamma_radSVM = best_gamma)

#store the best model
radSVM_BestModel <- best_model_list[which.min(cv_mse)]
saveRDS(radSVM_BestModel, "SVM/BestSVMModels/BestRadModel.rds")

write.csv(radSVMTuning_Results,"SVM/Results/radSVM.csv", row.names = FALSE)
