# EDA for nycflights data
# In order to create a spark dataframe we use createDataFrame
# script adapted from: http://rpubs.com/Thong/data-analysis-with-r-and-spark

# Clear the workspace
rm(list = ls())
# LOAD REQUIRED LIBRARIES
library(nycflights13)
library(dplyr)
library(magrittr)
library(sparklyr)

# connecting to spark local cluster
sc <- spark_connect(master = "local", version = "1.6.2")
# print the spark version
spark_version(sc)
# check data tables in spark local cluster
src_tbls(sc)
# Copy data to spark local instance
flights_tbl <- copy_to(sc, nycflights13::flights, "flights", overwrite = TRUE)
# check data dimension
dim(flights_tbl)
# check amount of memory taken up by the flights_tbl tibble
object.size(flights_tbl)
# check colnames data table
colnames(flights_tbl)

# USING SQL 
#  It’s also possible to execute SQL queries directly against tables within a Spark cluster. The spark_connection object implements a DBI interface for Spark, so you can use dbGetQuery to execute SQL and return the result as an R data frame
library(DBI)
flights2013<- tbl(sc, sql("select flight, tailnum, origin, dest FROM flights where year=2013"))
str(flightdetail.df)

# Writing Data to a local .csv file
spark_write_csv(flights2013,"local_csv_file/flights2013.csv", header=TRUE)

# dplyr usage
airportcounts <- flights_tbl %>% 
  filter(dest %in% c('ALB', 'BDL', 'BTV')) %>%
  group_by(year, month, dest) %>%
  summarise(count = n()) %>% 
  collect()
# filter by departure delay and print the first few records
flights_tbl %>% filter(dep_delay == 2)

delay <- flights_tbl %>% 
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect

# plot delays
library(ggplot2)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth(method = "loess") +
  scale_size_area(max_size = 2)

# MACHINE LEARNING (ML) using ML functions within sparklyr

# copy mtcars into spark
mtcars_tbl <- copy_to(sc, mtcars)
# check data tables in spark local cluster
src_tbls(sc)
# transform our data set, and then partition into 'training', 'test'
partitions <- mtcars_tbl %>%
  filter(hp >= 100) %>%
  mutate(cyl8 = cyl == 8) %>%
  sdf_partition(training = 0.5, test = 0.5, seed = 1099)

# fit a linear model to the training dataset
fit <- partitions$training %>%
  ml_linear_regression(response = "mpg", features = c("wt", "cyl"))
fit
# For linear regression models produced by Spark, we can use summary() to learn a bit more about the quality of our fit, and the statistical significance of each of our predictors.
summary(fit)





# stop the spark local cluster
spark_disconnect(sc)
