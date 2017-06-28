library(bigrquery)
project<- "voyage-2017"
sql <- "SELECT year, month, day, weight_pounds FROM [publicdata:samples.natality] LIMIT 5"
query_exec(sql, project = project)
