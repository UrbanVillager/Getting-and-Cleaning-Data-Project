library(data.table)
library(dplyr)
library(readr)
library(reshape2)

## Downloading Data Files
filename <- "getdata_dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


## Loading Files
SubjectTest <- fread("UCI HAR Dataset/test/subject_test.txt")
SubjectTrain <- fread("UCI HAR Dataset/train/subject_train.txt")

ActivityTest <- fread("UCI HAR Dataset/test/y_test.txt")
ActivityTrain <- fread("UCI HAR Dataset/train/y_train.txt")

ReadingsTest <- fread("UCI HAR Dataset/test/X_test.txt")
ReadingsTrain <- fread("UCI HAR Dataset/train/X_train.txt")

VariableNames <- fread("UCI HAR Dataset/features.txt")

ActivityLabels <- fread("UCI HAR Dataset/activity_labels.txt")

## Merging Data Set
Subjects <- tbl_df(rbind(SubjectTrain,SubjectTest))
Activities <- tbl_df(rbind(ActivityTrain,ActivityTest))
Readings <- tbl_df(rbind(ReadingsTrain,ReadingsTest))

## Matching Activities with their respective labels
Activities$V2 <- ActivityLabels$V2[match(Activities$V1,ActivityLabels$V1)]

## Finding indexes of mean and standard variation variables
col <- grep("mean|std",VariableNames$V2)

## Subsetting mean and standard variation variable columns
ReqReading <- Readings[,col]

## Assigning corresponding variable names
colname <- unlist(VariableNames$V2[col])
colnames(ReqReading) <- colname

## Combining Subjects, Activities and their corresponding Readings
TidyData <- cbind(Subjects,Activities$V2,ReqReading)
TidyData <- rename(TidyData, Subject = V1, Activity = `Activities$V2`)

## Converting Activity and Subject into factors
TidyData$Activity <- as.factor(TidyData$Activity)
TidyData$Subject <- as.factor(TidyData$Subject)

## Moulding Data into desired form
TidyData.melted <- melt(TidyData, id = c("Subject", "Activity"))
TidyData.mean <- dcast(TidyData.melted, Subject + Activity ~ variable, mean)

## Writing result to a text file
write.table(TidyData.mean,"TidyData.txt", row.names = F, quote = F)