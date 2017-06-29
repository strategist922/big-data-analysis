library(bigrquery)
project<- "voyage-2017"
sql <- "SELECT year, month, day, weight_pounds FROM [publicdata:samples.natality]
DESC LIMIT 10 "
data.df<-query_exec(sql, project = project)
str(data.df)

# Querying sample dataset containing a list of wikipedia entries.
sql <- 'SELECT title,contributor_username,comment FROM[publicdata:samples.wikipedia] WHERE title CONTAINS "beer" LIMIT 100;'

data <- query_exec(sql, project = project)
str(data)

# List all tables in publicdata
??list_tables
list_tables("publicdata","samples")
