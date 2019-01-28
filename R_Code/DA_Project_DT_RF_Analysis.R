#Created by Ashutosh Sharma
#Import packages
{library(VIM)
library(ggplot2)
library(rpart)
library(partykit)
library(randomForest)
library(reshape2)
library(tidyr)
library("mice")}


#import imputed data
df_rf_imputed_final <- read.csv("imputed_data.csv",header = TRUE)
df_rf_imputed_final <- df_rf_imputed_final[-c(1)]
cols <- c(1:2,10:16)
df_rf_imputed_final[cols]<-lapply(df_rf_imputed_final[cols],factor)
str(df_rf_imputed_final)

#######################################################Training and Test Data split#######################################
#Data split into training and testing
trainIndex  <- sample(1:nrow(df_rf_imputed_final), 0.80 * nrow(df_rf_imputed_final))
train <- df_rf_imputed_final[trainIndex,]
test <- df_rf_imputed_final[-trainIndex,]
nrow(df_rf_imputed_final)
nrow(train)
nrow(test)

#######################################################Decision Tree######################################################
#Create a decision tree model
DT_Model <- rpart(train$Response~., data=train)
print(DT_Model$variable.importance)
plot(as.party(DT_Model))
jpeg('Decision_Tree_RandomForest_Logistic_Imputation.jpg',width = 1920,height = 1080)
plot(as.party(DT_Model))
dev.off()

#Predict response for the test data
pred_DT = predict(DT_Model,test,type="class")

#Plot confusion matrix and calculate accuracy of the decision tree
confMat_DT <- table(pred_DT,test$Response)
accuracy_DT <- sum(diag(confMat_DT))/sum(confMat_DT)
accuracy_DT
table(pred_DT,test$Response)

#######################################################DecisionTree Pruning#################################################
#Plot Complexity parameter table of the above Decision Tree
plotcp(DT_Model)
print(DT_Model$cptable)
opt <- which.min(DT_Model$cptable[,"xerror"])
cp <-DT_Model$cptable[opt,"CP"]
#Prune the decision tree
DT_Model_Pruned <- prune(DT_Model, cp=cp)
plot(as.party(DT_Model_Pruned))

#Predict response for the test data using the pruned DT_Model, Plot the confusion matrix and calculate accuracy
pred_pr_DT = predict(DT_Model_Pruned,test,type="class")
confMat_pr_DT <- table(pred_pr_DT,test$Response)
accuracy_pr_DT <- sum(diag(confMat_pr_DT))/sum(confMat_pr_DT)
accuracy_DT
accuracy_pr_DT
table(pred_pr_DT,test$Response)


#######################################################RandomForest#########################################################
#Create a RandomForest model on the training data

RF <- randomForest(Response~., data=train)
print(RF)
importance(RF)
varImpPlot(RF)

#Predict response for the test data using the RF_Model, Plot the confusion matrix and calculate accuracy
pred_RF<-predict(RF,test)
confMat_RF <- table(pred_RF,test$Response)
accuracy_RF <- sum(diag(confMat_RF))/sum(confMat_RF)


#Final Accuracy of all the models and confusion matrix
accuracy_DT
table(pred_DT,test$Response)
accuracy_pr_DT
table(pred_pr_DT,test$Response)
accuracy_RF
table(pred_RF,test$Response)
