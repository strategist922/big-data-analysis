# EDA for nycflights data
# In order to create a spark dataframe we use createDataFrame

flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
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