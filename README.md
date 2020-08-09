## Peer-graded Assignment: Getting and Cleaning Data - Course Project

This repository contains results from the final project of the course "Getting and Cleaning Data" by Johns Hopkins University.

This project is based on the dataset: [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

---

Files description:

  - **CodeBook.md**: a code book that describes the variables.
  - **tidyDataset.txt/csv**: independent tidy data set with the average of each variable for each activity and each subject.
  - **run_analysis.R**: an R script that downloads, unzips, merges and creates the tidyDataset.
  
---

### **How the `run_analysis.R` script works:**

#### **Step 0**: Check if the necessary data is already availabre in the working directory, if not the script download and unzip the data.
  
```r
# Check if the data is available in the current folder
if (!'UCI_HAR_Dataset.zip' %in% dir()){
  
  # Download the data
  download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
                destfile = 'UCI_HAR_Dataset.zip')
  
  # Unzip the files
  unzip('UCI_HAR_Dataset.zip')
  
}
```

#### **Step 1**: Merges the training and the test sets to create one data set.
  
First, all the necessary data is imported and organized.
    
```r
# Import training 'variables names' and 'activities labels'
features <- read.table('UCI HAR Dataset/features.txt')
activity_labels <- read.table('UCI HAR Dataset/activity_labels.txt', stringsAsFactors = F)

### Organizing training data ###

# Import training data (values, activities and subject)
x_train <- read.table('UCI HAR Dataset/train/X_train.txt')
y_train <- read.table('UCI HAR Dataset/train/y_train.txt')
subject_train <- read.table('UCI HAR Dataset/train/subject_train.txt')

# rename training columns
colnames(x_train) <- features$V2

# Join training values, activities and subject
train_data <- cbind(subject  = subject_train$V1,
                    activity = y_train$V1,
                    x_train)

### Organizing test data ###

# Import training data (values, activities and subject)
x_test <- read.table('UCI HAR Dataset/test/X_test.txt')
y_test <- read.table('UCI HAR Dataset/test/y_test.txt')
subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt')

# rename test columns
colnames(x_test) <- features$V2

# Join test values, activities and subject
test_data <- cbind(subject  = subject_test$V1,
                   activity = y_test$V1,
                   x_test)
```

Then, the data is merged:

```r
### Merging training and test data ###

unified_dataset <- rbind(train_data, test_data)
```

#### **Step 2**: Extracts only the measurements on the mean and standard  deviation for each measurement.
  
This part was performed using `grep()` function with the pattern `mean|std` in the name of the columns:

```r
sub_data <- cbind(
  
  unified_dataset[1:2], # keep the two first columns (activity and subject)
  
  # Extracts only the measurements on the mean and std using grep
  unified_dataset[,3:ncol(unified_dataset)][,features[grep('mean|std', features$V2),][[1]]]
  
)
```

#### **Step 3**: Uses descriptive activity names to name the activities in the data set

Here the script replace the name of the activity based on the code provided in the `activity_labels.txt` file.

```r
for(i in 1:6) {
  
  sub_data$activity[sub_data$activity %in% i] <- activity_labels$V2[[i]]
  
}; rm(i)
```

#### **Step 4**: Appropriately labels the data set with descriptive variable names.

the current data set (sub_data) already has the
described labels of the variables provided in the
'features.txt' file, so I just decided to only apply
the clean_names() function of the janitor package if
the package is available in the current session.

```r
if (require(janitor)) {
  
  sub_data <- janitor::clean_names(sub_data, 'small_camel')
  
}
```

#### **Step 5**: From the data set in step 4, creates a second independent tidy data set with the average of each variable for each activity and each subject

Here I decided to customize a function to calc the mean
values for all variables for each activity and each subject.

```r
calc_avg <- function(subject, activity){
  
  # subset by specific subject and activity
  dt <- sub_data
  dt <- dt[dt$subject == subject & dt$activity == activity,]
  
  # calc mean values for all variables
  avg_values <- sapply(colnames(dt[3:ncol(dt)]), function(i){
    
    mean(dt[[i]])
    
  })
  
  result <- data.frame(subject = subject,
                       activity = activity,
                       t(avg_values))
  
  # return the data
  return(result)
  
}
```

Then, using the calc_avg function I calc the
mean for for all variables for each activity and each subject
and save in a list called 'result' using lapply.

```r
result <- lapply(1:30, function(j) {
  
  lapply(activity_labels$V2, function(i) {calc_avg(j, i)})
  
})
```

Create a empty data.frame with the variables names and add all the results to this data.frame

```r
avgTidyDataset <- sub_data[0,]

for (j in seq_along(result)){
  for (i in seq_along(result[[j]])){
    
    avgTidyDataset <- rbind(avgTidyDataset, result[[j]][[i]])
    
  }
}; rm(i, j)
```

Rename the columns to begin with 'Average_'

```r
colnames(avgTidyDataset)[3:ncol(avgTidyDataset)] <- 
  paste0('Average_', colnames(avgTidyDataset)[3:ncol(avgTidyDataset)])
```

Show the final data set

```r
View(avgTidyDataset)
```
