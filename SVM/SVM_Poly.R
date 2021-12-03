
set.seed(1)

#convert USDA.grade to factor
gradeDF$USDA.grade <- as.factor(gradeDF$USDA.grade)

min_components <- 2 # it was found that components less than 15 did not perform optimally
max_components <- 80
component_seq <- seq(min_components,max_components)
degreeVec <- seq(1,4)

best_cost <- rep(NA, length(component_seq))
cv_mse <- rep(NA, length(component_seq))
best_degree <- rep(NA, length(degreeVec))
best_model_list <- vector(mode="list", length=length(component_seq))   

min_cost <- .01
max_cost <- 10

abs_min_cost_poly <- min_cost
abs_max_cost_poly <- max_cost

for (i in seq(length(component_seq))) {
  num_components <- component_seq[i]
  
  loadingDF <- pca_loadings[,1:num_components] # store the correct loadings DF
  
  scoresDF <- as.data.frame(as.matrix(predictorsDF) %*% as.matrix(loadingDF)) #compute the scores (z-values) for the given number of principal components
  scoresDF$USDA.grade <- gradeDF$USDA.grade
  
  
  costVec <- seq(from = min_cost, to = max_cost, length.out =20)
  
  TuneObj <- tune.svm(USDA.grade~ ., data = scoresDF, kernel = "polynomial", degree=degreeVec, scale=TRUE, cost = costVec)
  
  bcost_temp <- TuneObj$best.parameters[1,2]
  
  temp_min_cost <- min_cost
  temp_max_cost <- max_cost
  
  rerun_bool <- FALSE
  
  if (bcost_temp == min_cost) {
    temp_min_cost <- min_cost/100
    temp_max_cost <- min_cost
    rerun_bool <- TRUE
  } else if (bcost_temp == max_cost) {
    temp_max_cost <- max_cost*100
    temp_min_cost <- max_cost
    rerun_bool <- TRUE
  }
  
  if (rerun_bool) {
    costVec <- seq(from = temp_min_cost, to = temp_max_cost, length.out = 20) 
    TuneObj <- tune.svm(USDA.grade~ ., data = scoresDF, kernel = "polynomial", degree=degreeVec, scale=TRUE, cost = costVec)
  }
  
  abs_max_cost_poly <- max(abs_max_cost_poly, temp_max_cost)
  abs_min_cost_poly <- min(abs_min_cost_poly, temp_min_cost)
  
  best_cost[i] <- TuneObj$best.parameters[1,2]
  best_degree[i] <- TuneObj$best.parameters[1,1]
  best_model_list[[i]] <- TuneObj$best.model
  cv_mse[i] <- TuneObj$best.performance
}

PrincipalComponent <- seq(min_components,max_components)

polySVM_Results <- data.frame(PrincipalComponents = PrincipalComponent, CV_MSE_polySVM = cv_mse, Best_Cost_polySVM = best_cost, Best_Degree = best_degree)
polySVM_BestModel <- best_model_list[which.min(cv_mse)]
saveRDS(polySVM_BestModel, "SVM/BestSVMModels/BestPolyModel.rds")

write.csv(polySVM_Results,"SVM/Results/PolySVM.csv", row.names = FALSE)
