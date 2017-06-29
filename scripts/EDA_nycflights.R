# EDA for nycflights data
# In order to create a spark dataframe we use createDataFrame
# script adapted from: http://rpubs.com/Thong/data-analysis-with-r-and-spark

# connecting to spark local cluster
sc <- spark_connect(master = "local")

flights_tbl <- copy_to(sc, nycflights13::flights, "flights", overwrite = TRUE)
# check data dimension
dim(flights_tbl)
# check amount of memory taken up by the flights_tbl tibble
object.size(flights_tbl)
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



# stop the spark local cluster
spark_disconnect(sc)
