# Getting and Cleaning Data - Course Project

# Download and unzip data

# Check if the data is available in the current folder
if (!'UCI_HAR_Dataset.zip' %in% dir()){
  
  # Download the data
  download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
                destfile = 'UCI_HAR_Dataset.zip')
  
  # Unzip the files
  unzip('UCI_HAR_Dataset.zip')
  
}

#############################################
#### 1. Merges the training and the test ####
####    sets to create one data set      ####
#############################################

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

### Merging training and test data ###

unified_dataset <- rbind(train_data, test_data)

# removing unnecessary data from the memory
rm(subject_test,
   subject_train,
   x_train,
   x_test,
   y_train,
   y_test,
   train_data,
   test_data)

###########################################################
#### 2. Extracts only the measurements on the mean and ####
####    standard  deviation for each measurement       ####
###########################################################

sub_data <- cbind(
  
  unified_dataset[1:2], # keep the two first columns (activity and subject)
  
  # Extracts only the measurements on the mean and std using grep
  unified_dataset[,3:ncol(unified_dataset)][,features[grep('mean|std', features$V2),][[1]]]
  
)

################################################
#### 3. Uses descriptive activity names to  ####
####    name the activities in the data set ####
################################################

for(i in 1:6) {
  
  sub_data$activity[sub_data$activity %in% i] <- activity_labels$V2[[i]]
  
}; rm(i)

###############################################
#### 4. Appropriately labels the data set  ####
####    with descriptive variable names    ####
###############################################

# the current data set (sub_data) already has the
# described labels of the variables provided in the
# 'features.txt' file, so I just decided to only apply
# the clean_names() function of the janitor package if
# the package is avaiable in the current session

if (require(janitor)) {
  
  sub_data <- janitor::clean_names(sub_data, 'small_camel')
  
}

#############################################################
#### 5. From the data set in step 4, creates a second    ####
####    independent tidy data set with the average of    ####
####    each variable for each activity and each subject ####
#############################################################

# Here I decided to customize a function to calc the mean
# values for all variables for each activity and each subject

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

# Then, using the calc_avg function I calc the
# mean for for all variables for each activity and each subject
# and save in a list called 'result' using lapply

result <- lapply(1:30, function(j) {
  
  lapply(activity_labels$V2, function(i) {calc_avg(j, i)})
  
})

# Create a empty data.frame with the variables names

avgTidyDataset <- sub_data[0,]

# Then, I add all the results in a single data.frame

for (j in seq_along(result)){
  for (i in seq_along(result[[j]])){
    
    avgTidyDataset <- rbind(avgTidyDataset, result[[j]][[i]])
    
  }
}; rm(i, j)

# Rename the columns to begin with 'Average_'

colnames(avgTidyDataset)[3:ncol(avgTidyDataset)] <- 
  paste0('Average_', colnames(avgTidyDataset)[3:ncol(avgTidyDataset)])

# Show the final data set

View(avgTidyDataset)

# Save the final tidy data set in txt and csv

write.table(avgTidyDataset, file = 'tidyDataset.txt', row.name = FALSE)
write.csv(avgTidyDataset, file = 'tidyDataset.csv', row.names = F)
