# project-5
Group 5 Project for DSCI445 @ CSU


# Sources
- https://www.kaggle.com/datasets/davidjfisher/illinois-doc-labeled-faces-dataset/data
- https://drive.google.com/drive/folders/1XqyE_XdYWNoK3NAcTxp41hUJ13zu1Qbr?usp=sharing

# Reproducibility - IMPORTANT
## data cleaning
The kaggle dataset provided us with three csv files: marks.csv, sentencing.csv, and person.csv. 
Cleaning for each dataset was done in separate R files: 
marks_data_cleaning.R, sentencing_data_cleaning.R, and person_data_cleaning.R respectively. 
After each dataset was cleaned, all three were merged into one dataset called merged_data.csv in the file combine_data.R.
These R files do not need to be rerun 
in order for the analysis to work, but still exist within the project for reproducibility. 
All csvs are found in the CSV_Files folder. All data cleaning files are found in the Code folder.

## models
The models were each fit in a separate Rmd file.

- KNN: KNNAaron.Rmd
- Random Forest: RFJuan.Rmd
- Linear regression: linear_regression_Hope.Rmd
- GAM: SentencingGAM.rmd

All four of these files are found in the Code folder. 
Again, these files do not need to be rerun to see the results in either the presentation or paper. 
In particular, as a warning, the fitting of the Random Forest and KNN models takes a substantial amount of time.

## presentation
- You can find the quarto markdown file for our slides saved as "Presentation.qmd" in the "Presentation" folder. 
- To run the file it requires you to download our random forest model using the link to the google drive under Sources just above this. It was too big a file to push to github (117.5 MB).
- If you upload the random forest rds to the Code folder, you should not need to change the file path. If you store the rds anywhere else, add your local path on line 293 and make sure any other paths to that file are commented out.
- Only issues when running our slides is that we couldn't figure out how to change the font size on quarto. This only effects slides 2 and 13, which we adjusted the font for manually before presenting.

## paper
- Our paper is saved in the "Code" folder under the file name "paper.Rmd"
- You must do the same with the rds file for the random forest model on line ###


# Questions we want answered
- What predictors have the strongest effect on sentencing length?

- How accurately can we predict sentencing length?

- What predictors have the strongest effect on offence category?

- How accurately can we predict offence categories?

# Methods for answering these questions
- Cross validation

- LASSO

- KNN

# Create one model per person and then rejoin to discuss results
- Linear Regression (Hope)
    - LASSO
    - Forwards Subset
    - Backwards Subset

- Random forest (Juan)

- KNN (Aaron)

- generalized additive model (Ilijah)
    - with splines
    - polynomial




