# project-5
Group 5 Project for DSCI445 @ CSU


# Dataset
https://www.kaggle.com/datasets/davidjfisher/illinois-doc-labeled-faces-dataset/data

# Questions we want answered
- What predictors have the strongest effect on sentencing length?

- How accurately can we predict sentencing length?

- What predictors have the strongest effect on offence category?

- How accurately can we predict offence categories?

# Data cleaning
The kaggle dataset provided us with three csv files: marks.csv, sentencing.csv, and person.csv. 
Cleaning for each dataset was done in separate R files. These R files do not need to be rerun 
in order for the analysis to work, but still exist within the project for reproducibility. After 
each dataset was cleaned, all three were merged into one dataset called merged_data.csv.

# Methods for answering these questions
- Cross validation

- LASSO

- KNN

# Create one model per person and then rejoin to discuss results
- Linear Regression (Hope)
-- interactions

- Random forest (Juan)
-- with bagging
-- with boosting

- KNN (Aaron)

- generalized additive model (Ilijah)
-- with splines
-- polynomial


