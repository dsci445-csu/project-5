
set.seed(1)

#recompute principal components with na removed
data <- na.omit(ten28DF)
predictorsDF <- data[,!(names(data) %in% c("Ten28"))] # dataframe without response
pca_obj <- prcomp(predictorsDF, center=TRUE, scale=TRUE)  # perform PCA
pca_summary <- summary(pca_obj)
pca_loadings <- pca_obj$rotation #store the loading vectors for future use

lambda_min <- 0
lambda_max <- 3

lambda_min_under <- -1
lambda_max_over <- 10

min_components <- 2
max_components <- 50
components_seq <- seq(min_components, max_components)

best_lambda <- rep(NA, length(components_seq))
cv_mse <- rep(NA, length(components_seq))
best_model_list <- vector(mode="list", length=length(components_seq))
size_list <- rep(NA, length(components_seq))

for (i in seq(length(components_seq))) {
  
  lambda <- 10^seq(lambda_min, lambda_max, length.out = 1000)
  
  num_components <- components_seq[i]
  loadingDF <- pca_loadings[,1:num_components] # store the correct loadings DF
  #compute the scores (z-values) for the given number of principal components
  scoresDF <- as.data.frame(as.matrix(predictorsDF) %*% as.matrix(loadingDF))
  scoresDF$Ten28 <- data$Ten28
  
  
  #set.seed(1)
  n<-nrow(scoresDF)
  TrainData <- scoresDF
  X_train <- model.matrix(Ten28 ~ ., data = TrainData)[,-1]
  Y_train <- TrainData$Ten28
  
  cv_lasso <- cv.glmnet(X_train, Y_train, alpha = 1, lambda = lambda)
  
  lambdaMinSolutionTemp <- cv_lasso$lambda.min
  
  temp_lambdaMin <- lambda_min
  temp_lambdaMax <- lambda_max
  resolve_bool <- FALSE
  
  if (isTRUE(all.equal(lambdaMinSolutionTemp,10^temp_lambdaMin))) {
    temp_lambdaMin <- lambda_min_under
    temp_lambdaMax <- lambda_min
    resolve_bool <- TRUE
    isTRUE(all.equal(i,0.15))
  } else if (isTRUE(all.equal(lambdaMinSolutionTemp,10^temp_lambdaMax))) {
    temp_lambdaMin <- 8
    temp_lambdaMax <- 10
    resolve_bool <- TRUE
  }
  
  if (resolve_bool) {
    lambda <- 10^seq(temp_lambdaMin, temp_lambdaMax, length.out = 1000)
    cv_lasso <- cv.glmnet(X_train, Y_train, alpha = 1, lambda = lambda)
  }
  
  lambdaMinActual <- cv_lasso$lambda.min
  cv_error <- min(cv_lasso$cvm)
  
  lasso_mdl <-  glmnet(X_train, Y_train, alpha = 1, lambda = lambdaMinActual)
  
  coefs_all <- coef(lasso_mdl)
  size <- length(coefs_all[coefs_all[,1]!=0,]) - 1
  
  cv_mse[i] <- cv_error    
  best_lambda[i] <- lambdaMinActual
  size_list[i] <- size
  best_model_list[[i]] <- lasso_mdl
}


lassoPCA_Results <- data.frame(PrincipalComponents = components_seq, CV_MSE = cv_mse, Best_Lambda = best_lambda, Size=size_list)
#store the best model
lassoTen28_BestModel <- best_model_list[which.min(cv_mse)]
saveRDS(lassoTen28_BestModel, "Lasso/BestModels/BestLassoTen28Model.rds")


write.csv(lassoPCA_Results,"Lasso/Results/Ten28.csv", row.names = FALSE)
