### Code Book

This code Book describes the variable in the tidyDataset.csv/txt file. This dataset is build using the `run_analisys.R` script.

First, the name of the variables was converted to small camel case with the function `clean_names()` from the package `janitor`.

Then, the final names was combined with the "Average_" string to represent the final names.

Description:

  - **subject**: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
  - **activity**: Each row is one of the six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
  - **Average_'feature'**: the average value of each original variable for each activity and each subject.