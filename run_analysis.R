library("reshape2")

# Download Source file

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

#unzip files 
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#Load activity
activity_labels <- read.table("data/UCI HAR Dataset/activity_labels.txt")[,2]

#Load features
features <- read.table("data/UCI HAR Dataset/features.txt")[,2]

#extract mean and std from features
m_std <- grepl("mean\\(\\)|std\\(\\)", features)

#Load into data frames for test and train 
X_test <- read.table("data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("data/UCI HAR Dataset/test/subject_test.txt")
X_train <- read.table("data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("data/UCI HAR Dataset/train/subject_train.txt")

#update X names from features
names(X_test) = features
names(X_train) = features

#extract only mean and std measures using m_std <- grepl("mean|std", features)
X_test = X_test[,m_std]
X_train = X_train[,m_std]

#add activity labels to Y so there will be 2 fields
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity", "Activity_Label")

y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity", "Activity_Label")

#update subject name

names(subject_test) = "subject"
names(subject_train) = "subject"

#bind test
test <- cbind.data.frame(subject_test, cbind.data.frame(y_test, X_test))

#bind train
train <- cbind.data.frame(subject_train, cbind.data.frame(y_train, X_train))

#bind test and train
combined <- rbind(train, test)

#creat tidy data sets
IDs <- c("subject", "Activity", "Activity_Label")
Measures <- setdiff(colnames(combined), IDs)
melted <- melt(combined, id = IDs, measure.vars = Measures)

tidy_sets <- dcast(melted, subject + Activity_Label ~ variable, mean)

#write output file
write.table(tidy_sets, "tidy.txt", row.names=FALSE)