

#You should create one R script called run_analysis.R that does the following. 

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")


unzip("./data/Dataset.zip",exdir="./data")

path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files


#Read the Activity files

activity.test.data  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
activity.train.data <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#Read the Subject files

subject.train.data <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
subject.test.data  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Read Fearures files

features.test.data  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
features.train.data <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

# 1. Merges the training and the test sets to create one data set.

data <- rbind(cbind(subject.test.data, activity.test.data, features.test.data),cbind(subject.train.data, activity.train.data, features.train.data))


# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

features.names.data <- read.table(file.path(path_rf, "features.txt"),strip.white=TRUE, stringsAsFactors=FALSE)

features.mean.final <- features.names.data[grep("mean\\(\\)|std\\(\\)", features.names.data$V2), ]

data.mean <- data[, c(1, 2, features.mean.final$V1+2)]


# 3. Uses descriptive activity names to name the activities in the data set

labels <- read.table(file.path(path_rf, "activity_labels.txt"),stringsAsFactors=FALSE)

data.mean$label <- labels[data.mean$label, 2]


# 4. Appropriately labels the data set with descriptive variable names.

# list of the current column names and feature names
good.colnames <- c("subject", "label", features.mean.final$V2)

#removing non-alphabetic character
good.colnames <- tolower(gsub("[^[:alpha:]]", "", good.colnames))

# use the list as column names for data
colnames(data.mean) <- good.colnames

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
aggr.data <- aggregate(data.mean[, 3:ncol(data.mean)],
                       by=list(subject = data.mean$subject,
                               label = data.mean$label),
                       mean)


write.table(format(aggr.data, scientific=T), "tidyFinal1.txt",
            row.names=F, col.names=F, quote=2)


