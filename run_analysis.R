setwd("C:/Users/85340/Desktop/getdata_projectfiles_UCI HAR Dataset")
library(dplyr)
#----Read----
# Read feature names
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("feature_id", "feature_name"))

# Read training data
train_data <- read.table("UCI HAR Dataset/train/X_train.txt")
train_labels <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity_id")
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject_id")

# Read test data
test_data <- read.table("UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activity_id")
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject_id")

# Merge the training and test data sets
merged_data <- rbind(train_data, test_data)
merged_labels <- rbind(train_labels, test_labels)
merged_subject <- rbind(train_subject, test_subject)

#----
# Extract feature names for mean and standard deviation
mean_std_features <- grep("mean\\(\\)|std\\(\\)", features$feature_name)
clean_feature_names <- features$feature_name[mean_std_features]

# Read activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_id", "activity_name"))

#----Subset----
# Subset the merged data to include only mean and standard deviation features
subset_data <- merged_data[, mean_std_features]
# Merge the activity labels with the subset_data
subset_data <- cbind(merged_labels, subset_data)
subset_data <- merge(activity_labels, subset_data, by = "activity_id")

# Remove the activity_id column
subset_data <- subset_data[, -1]

#----
# Clean up and format the feature names
clean_feature_names <- gsub("mean\\(\\)", "Mean", clean_feature_names)
clean_feature_names <- gsub("std\\(\\)", "StdDev", clean_feature_names)

#----
# Assign the cleaned feature names to the subset_data columns
colnames(subset_data)[2:ncol(subset_data)] <- clean_feature_names
# Group by subject_id and activity_name, and calculate the mean for each variable

subset_data <- cbind(merged_subject, subset_data)
tidy_data <- subset_data %>%
        group_by(subject_id, activity_name) %>%
        summarise(across(everything(), mean))

# Write the tidy data set to a file
write.table(tidy_data, file = "tidy_data.txt", row.names = FALSE)
