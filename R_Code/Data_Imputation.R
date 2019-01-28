#Created by Ashutosh Sharma
#Import packages
setwd("D:/Trinity_DS/DataAnalytics/Project/Phase2/Phase3")
{
  library(VIM)
  library(ggplot2)
  library(rpart)
  library(partykit)
  library(randomForest)
  library(reshape2)
  library(tidyr)
  library("mice")
}

#######################################################Create required functions#######################################
{
  corr_heatmap <- function (df)
  {
    mydata <- df
    cormat <- round(cor(mydata,use="complete.obs"),2)
    melted_cormat <- melt(cormat)
    head(melted_cormat)
    #ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
    #  geom_tile()
    # Get upper triangle of the correlation matrix
    get_upper_tri <- function(cormat){
      cormat[lower.tri(cormat)]<- NA
      return(cormat)
    }
    cormat
    upper_tri <- get_upper_tri(cormat)
    
    head(melted_cormat)
    # Melt the correlation matrix
    melted_cormat <- melt(upper_tri, na.rm = TRUE)
    # Create a ggheatmap
    ggheatmap <- ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
      geom_tile(color = "white")+
      scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                           midpoint = 0, limit = c(-1,1), space = "Lab", 
                           name="Pearson\nCorrelation") +
      theme_minimal()+ 
      theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                       size = 12, hjust = 1))+
      coord_fixed()
    ggheatmap + 
      geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.ticks = element_blank(),
        legend.justification = c(1, 0),
        legend.position = c(0.6, 0.7),
        legend.direction = "horizontal")+
      guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
                                   title.position = "top", title.hjust = 0.5))
  }
  randomImputation <- function (df)
  { cols <- c(1:2,10:16)
  df[cols] <-lapply(df[cols],factor)
  for(a in colnames(df)){
    missing <- is.na(df[a])
    n.missing <- sum(missing)
    a.obs <- df[a][!missing]
    imputed <- df[a]
    imputed[missing] <- sample (a.obs, n.missing, replace=TRUE)
    df[a]<- imputed
  }
  return (df)
  }
  
  hist_plot <- function(df)
  {
    df[complete.cases(df), ] %>% gather() %>% head()
    ggplot(gather(df[complete.cases(df), ]), aes(value)) + 
      geom_histogram(bins = 10) + 
      facet_wrap(~key, scales = 'free_x')
  }
}
#######################################################################################################################




#######################################################Import dataset###################################################
{
  setwd("D:/Trinity_DS/DataAnalytics/Project/Phase2/")
  df_orignal <- read.csv("Project_Data.csv",header = TRUE)
  df_orignal <- df_orignal[,-c(1)]
  df_orignal_bckup<-df_orignal
  cols <- c(1:2,10:16)
  df_orignal_bckup[cols] <-lapply(df_orignal[cols],factor)
  df_orignal[cols]<-lapply(df_orignal[cols],factor)
  
}

#######################################################Analyze missing data###############################################
#Missingness pattern using mice package
md.pattern(df_orignal)
str(df_orignal)

#######################################################Data Imputation#####################################################
#Simple Random Imputation
df_random_imputed <- randomImputation (df_orignal)

#Multivariate Imputation by Chained Equations(mice)
#Impute X's using RandomForest
{
  imp <- mice(df_orignal[c(2:9)], method = "rf" )
  df_rf_imputed <- complete(imp)
  densityplot(imp)
}
#Impute Y's using rules, randomforest & logistic regression
{
  df_rf_imputed <- cbind(df_rf_imputed,df_orignal[c(10:16)])
  df_rf_imputed$Y1 <- ifelse(df_rf_imputed$X1<=34,0,1)
  df_rf_imputed$Y2 <- ifelse(df_rf_imputed$X2<279,0,1) 
  df_rf_imputed$Y3 <- ifelse(df_rf_imputed$X3<=240,0,1)
  df_rf_imputed$Group
  temp <- df_rf_imputed[c(1,6,13)]
  t_imp <- mice(temp, method = "logreg" , m = 30)
  temp <- complete(t_imp)
  df_rf_imputed$Y5 <- temp$Y5
  
  
  temp<-  df_rf_imputed[c(7,14)]
  t_imp <- mice(temp, method = "rf" , m = 30)
  temp <- complete(t_imp)
  df_rf_imputed$Y6 <- temp$Y6  
  
  temp<-  df_rf_imputed[c(8,15)]
  t_imp <- mice(temp, method = "logreg" , m = 30)
  temp <- complete(t_imp)
  temp$Y7_act <-df_rf_imputed$Y7
  df_rf_imputed$Y7 <- temp$Y7 
  
}
#Mean of orignal data with missings removed
summary(df_orignal[c(3:9)])
#Mean of missings imputed using random imputation by random sampling  
summary(df_random_imputed[c(3:9)])
#Mean of missings imputed using RandomForest by mice package
summary(df_rf_imputed[c(2:8)])


#Notice the change in the distributions of a few columns
#df_orignal[complete.cases(df_orignal[c(3:9)]), ][c(3:9)]

hist_plot(df_orignal[c(3:9)])
hist_plot(df_random_imputed[c(3:9)])
hist_plot(df_rf_imputed[c(2:8)])

corr_heatmap(df_orignal[c(3:9)])
corr_heatmap(df_random_imputed[c(3:9)])
corr_heatmap(df_rf_imputed[c(2:8)])

summary(df_rf_imputed)
df_rf_imputed <- cbind(df_orignal[c(1)],df_rf_imputed)
setwd("D:/Trinity_DS/DataAnalytics/Project/Phase2/Phase3/")
write.csv(df_random_imputed,"Random_imputed_data.csv")
write.csv(df_rf_imputed,"imputed_data.csv")
  
    