set.seed(1)

#recompute principal components with na removed
data <- na.omit(ten3DF)
predictorsDF <- data[,!(names(data) %in% c("Ten3"))] # dataframe without response
pca_obj <- prcomp(predictorsDF, center=TRUE, scale=TRUE)  # perform PCA
pca_summary <- summary(pca_obj)
pca_loadings <- pca_obj$rotation #store the loading vectors for future use

lambda_min <- 0
lambda_max <- 3

lambda_min_under <- -2
lambda_max_over <- 8



min_components <- 2
max_components <- 50
components_seq <- seq(min_components, max_components)

best_lambda <- rep(NA, length(components_seq))
cv_mse <- rep(NA, length(components_seq))
best_model_list <- vector(mode="list", length=length(component_seq)) 


for (i in seq(length(components_seq))) {

  lambda <- 10^seq(lambda_min, lambda_max, length.out = 1000)
  
  num_components <- components_seq[i]
  loadingDF <- pca_loadings[,1:num_components] # store the correct loadings DF
  #compute the scores (z-values) for the given number of principal components
  scoresDF <- as.data.frame(as.matrix(predictorsDF) %*% as.matrix(loadingDF))
  scoresDF$Ten3 <- data$Ten3
  
  
  #set.seed(1)
  n<-nrow(scoresDF)
  trn <- seq_len(n) %in% sample(seq_len(n), round(0.8*n))
  TrainData <- scoresDF[trn,]
  TestData <- scoresDF[!trn,]
  X_train <- model.matrix(Ten3 ~ ., data = TrainData)[,-1]
  Y_train <- TrainData$Ten3
  X_test <- model.matrix(Ten3 ~ ., data = TestData)[,-1]
  Y_test <- TestData$Ten3
  
  cv_lasso <- cv.glmnet(X_train, Y_train, alpha = 1, lambda = lambda)
  
  lambdaMinSolutionTemp <- cv_lasso$lambda.min
  
  temp_lambdaMin <- lambda_min
  temp_lambdaMax <- lambda_max
  resolve_bool <- FALSE
  
  if (lambdaMinSolutionTemp == 10^temp_lambdaMin) {
    temp_lambdaMin <- lambda_min_under
    temp_lambdaMax <- lambda_min
    resolve_bool <- TRUE
  } else if (lambdaMinSolutionTemp == 10^temp_lambdaMax) {
    temp_lambdaMin <- lambda_max
    temp_lambdaMax <- lambda_max_over
    resolve_bool <- TRUE
  }
  
  if (resolve_bool) {
    lambda <- 10^seq(temp_lambdaMin, temp_lambdaMax, length.out = 1000)
    cv_lasso <- cv.glmnet(X_train, Y_train, alpha = 1, lambda = lambda)
  }
  
  lambdaMinActual <- cv_lasso$lambda.min
  
  lasso_mdl <- glmnet(X_train, Y_train, alpha = 1, lambda = lambdaMinActual)
  
  predictions <- predict(lasso_mdl,newx=X_test,s=lambdaMinActual, type="response")
  
  testErrorLasso <- mean(( predictions[,'s1'] - Y_test )^2)
  
  cv_mse[i] <- testErrorLasso    
  best_lambda[i] <- lambdaMinActual
  best_model_list[[i]] <- lasso_mdl
}


lassoPCA_Results <- data.frame(PrincipalComponents = components_seq, CV_MSE = cv_mse, Best_Lambda = best_lambda)

#store the best model
lassoTen3_BestModel <- best_model_list[which.min(cv_mse)]
saveRDS(lassoTen3_BestModel, "Lasso/BestModels/BestLassoTen3Model.rds")

write.csv(lassoPCA_Results,"Lasso/Results/Ten3.csv", row.names = FALSE)