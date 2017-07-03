---
title: "Exploring sparklyr: regression, supervised and unsupervised machine learning algorithms"
author: "Ashish Dutt"
output: html_document
---

This document will explore some of the basic machine learning functions of MLlib interface in the new package *sparklyr* from **RStudio** that was just announced on June 29th 2016 at the *useR* conference! The *sparklyr* package also provides for an interface to use *dplyr* as well. 

### Installing and preparing sparklyr

The following lines of code will install *sparklyr*. sparklyr works with a full integration of the *dplyr* package. 

```{r, eval = FALSE}
#load sparklyr & dplyr
> devtools::install_github("rstudio/sparklyr")
> library(sparklyr)
> library(dplyr)

# install spark if not already installed
> spark_install(version = "2.1.0")
# check spark installed versions
> spark_installed_versions()
# Connecting to spark using spark_connect, on a local connection. 
> sc <- spark_connect(master = "local", version="2.1.0")
# print the spark version
> spark_version(sc)
# check data tables in spark local cluster
> src_tbls(sc) # If no table copied in local cluster, then NULL or character(0) will be returned

```

### Useful resources

Some useful resources on `SparkMlib` can be seen [here](http://spark.apache.org/docs/latest/ml-pipeline.html), on `Pipelines` canbe seen [here](http://spark.apache.org/docs/latest/ml-pipeline.html)

### Linear Regression

This will be an example of using Spark's linear regression model on the classic wine quality [data set](https://gist.github.com/duttashi/fc6f64ff9e28502826dea05d034773df). The code will compare the output from *sparklyr* and the base R `lm()` function.

This regression will try to predict wine quality based on its pH, alcohol, density, and wine type. 

```{r, eval = F}
# Loading local data
> wine <- read.csv("data/wine.csv")
> str(wine)
'data.frame':	5000 obs. of  13 variables:
 $ fixedAcidity      : num  6.95 7 5.98 6.69 7.22 ...
 $ volatileAcidity   : num  0.273 0.19 0.141 0.372 0.201 ...
 $ citricAcid        : num  0.404 0.31 0.251 0.508 0.221 ...
 $ residualSugar     : num  13.92 19.19 4.4 11.86 1.61 ...
 $ chlorides         : num  0.051 0.0441 0.0281 0.0449 0.045 ...
 $ freeSulfurDioxide : num  66.1 39.9 32.1 67.5 16.8 ...
 $ totalSulfurDioxide: num  246 176 152 156 122 ...
 $ density           : num  0.999 1 0.995 0.999 0.995 ...
 $ pH                : num  3.16 2.93 3.49 3.17 3.37 ...
 $ sulphates         : num  0.58 0.523 0.512 0.44 0.529 ...
 $ alcohol           : num  9.5 9.11 11.08 8.85 10.37 ...
 $ quality           : int  4 3 4 5 5 4 4 5 5 4 ...
 $ type              : Factor w/ 2 levels "Red","White": 2 2 2 2 2 1 1 2 1 1 ...
 
# The copy_to function copys the local data frame to a spark data table
> wine_tbl <- copy_to(sc, wine, overwrite=TRUE) 

# Set a seed for result reproducibility
> set.seed(11)
```

Let's first create our model using Spark's linear regression.

```{r, eval = F}
> fit <- wine_tbl %>% ml_linear_regression(response = "quality",
                                         features = c("pH", "alcohol", "density", "type"))
```

Now that we have created a working linear regression model using Spark, lets create the same model using the base R function lm().

```{r, eval = F}
# creating lm using base functions 
> fit_base <- lm(quality ~ pH + alcohol + density + type, data = wine_tbl)

> summary(fit)
Call: ml_linear_regression(., response = "quality", features = c("pH", "alcohol", "density", "type"))

Deviance Residuals::
     Min       1Q   Median       3Q      Max 
-3.09370 -0.50118  0.02525  0.50473  3.48359 

Coefficients:
               Estimate  Std. Error  t value  Pr(>|t|)    
(Intercept)  30.2243682   5.5927285   5.4042 6.811e-08 ***
pH           -0.0083494   0.0724080  -0.1153    0.9082    
alcohol      -0.3607972   0.0130215 -27.7077 < 2.2e-16 ***
density     -22.1625961   5.4908946  -4.0362 5.513e-05 ***
type_White   -0.2221567   0.0335749  -6.6168 4.057e-11 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

R-Squared: 0.2119
Root Mean Squared Error: 0.7732
> summary(fit_base)

Call:
lm(formula = quality ~ pH + alcohol + density + type, data = wine_tbl)

Residuals:
    Min      1Q  Median      3Q     Max 
-3.0937 -0.5012  0.0253  0.5047  3.4836 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)  30.224368   5.592729   5.404 6.81e-08 ***
pH           -0.008349   0.072408  -0.115    0.908    
alcohol      -0.360797   0.013022 -27.708  < 2e-16 ***
density     -22.162596   5.490895  -4.036 5.51e-05 ***
typeWhite    -0.222157   0.033575  -6.617 4.06e-11 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7736 on 4995 degrees of freedom
Multiple R-squared:  0.2119,	Adjusted R-squared:  0.2113 
F-statistic: 335.8 on 4 and 4995 DF,  p-value: < 2.2e-16
```
## K-Means Clustering

Now I will display how to create a k-means clustering algorithm using the same wine data set and the same response, and predictor variables.

```{r, eval = F}
> wine <- wine %>% mutate(white = ifelse(type == "White", 1, 0)) # convert type to numeric as k-means cannot handle factor values
'data.frame':	5000 obs. of  14 variables:
 $ fixedAcidity      : num  6.95 7 5.98 6.69 7.22 ...
 $ volatileAcidity   : num  0.273 0.19 0.141 0.372 0.201 ...
 $ citricAcid        : num  0.404 0.31 0.251 0.508 0.221 ...
 $ residualSugar     : num  13.92 19.19 4.4 11.86 1.61 ...
 $ chlorides         : num  0.051 0.0441 0.0281 0.0449 0.045 ...
 $ freeSulfurDioxide : num  66.1 39.9 32.1 67.5 16.8 ...
 $ totalSulfurDioxide: num  246 176 152 156 122 ...
 $ density           : num  0.999 1 0.995 0.999 0.995 ...
 $ pH                : num  3.16 2.93 3.49 3.17 3.37 ...
 $ sulphates         : num  0.58 0.523 0.512 0.44 0.529 ...
 $ alcohol           : num  9.5 9.11 11.08 8.85 10.37 ...
 $ quality           : int  4 3 4 5 5 4 4 5 5 4 ...
 $ type              : Factor w/ 2 levels "Red","White": 2 2 2 2 2 1 1 2 1 1 ...
 $ white             : num  1 1 1 1 1 0 0 1 0 0 ...
> base_kmeans <- kmeans(wine[, c("quality", "pH", "alcohol", "density", "white")], 3,
                      iter.max = 10)
```

Now that we have created our base k-mean clusters, lets see how they compare to the Spark k-means function.

```{r, eval = F}
# Create k-means using spark
> wine_tbl <- copy_to(sc, wine, overwrite = TRUE)
> spark_kmeans <-  wine_tbl %>% ml_kmeans(centers = 3, iter.max = 10,
                                        features = c("quality", "pH", "alcohol", "density", "white"))
```

Now that we have our models, lets compare their outputs.

```{r, eval = F}
# Time to compare the centers 
# creating data frame from kmeans centers
> base_centers <- data.frame(base_kmeans$centers)

# Printing centers of base and spark
> arrange(base_centers, quality)
   quality       pH   alcohol   density     white
1 3.530677 3.213740 11.945754 0.9929243 0.8709677
2 3.817809 3.208696  9.857289 0.9968302 0.8330404
3 5.116238 3.208921  9.728310 0.9969138 0.7517523

> arrange(spark_kmeans$centers, quality)
   quality       pH   alcohol   density     white
1 3.310078 3.214524 12.304778 0.9925461 0.8720930
2 4.053476 3.231603 10.757555 0.9949572 0.8324421
3 4.647702 3.192850  9.437199 0.9975047 0.7811816

```
The differences in the centers are quite minimal, perhaps due to randomness or differences in rounding.
