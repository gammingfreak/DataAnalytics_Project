# DataAnalytics Project

ABSTRACT: In this project, the given data has been analyzed using R. The dataset contains 16 columns named Response, Group, X1-X7 and Y1-Y7. Each column had missing values except Response, Group, X4 & Y4. Due to major missing data, first data imputation is performed then post imputation models are built to predict the target response. The data imputation is performed using two methods i.e. Simple Random Sampling Imputation (SRSI) and a model-based approach using Multivariate Data Imputation by Chained Equation (MICE) [1]. Both imputation methods are compared, and mice approach is selected for data imputation as it provided a better result. After the data imputation, for predictive analysis of response two models are built i.e. Decision Tree (DT) and Random Forest (RF) using all the predictors. The DT model is first created without any threshold then pruned later to overcome the overfitting. Fully grown DT had an accuracy of 70%; Pruned DT model had an accuracy of 71.6% whereas the RF model had an accuracy of 81.6%. Therefore, we conclude that the RF model is suitable for predicting the Response. Furthermore, the group was not a good predictor as it was not an important feature for the RF ensemble.

## Project on Data Analytics with data imputations, Decision Trees , Random Forest

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

The things you need to install the software and how to install them

```
R Studio
Data for this project is in the data directory.
```

### Installing

As the data contains a lot of missing values we first impute the missing vaules using the R Code : Data_Imputation.R.

Say what the step will be


Post that we implement the predictive model of decision tree and random forest to fit the model


The RandomForest model provides an accuracy of 77%.

## Authors

* **Ashutosh Sharma**


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

Dr. Bhaman Honari
