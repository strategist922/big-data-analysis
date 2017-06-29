# This script is to be used for testing sparkr and sparklyr connection on standalone pc.
# script created on: 27/5/2017

# install spark on local machine, if not already installed
sparklyr::spark_install()

# Load the libraries
library(sparklyr)
#details of my session
sessionInfo()

# Start spark cluster on local machine
sc<- spark_connect(master = "local")
# print the spark version
spark_version(sc)

# See which data frames are available in Spark, using 
src_tbls(sc)

# To view the spark web console
spark_web(sc)
# To see the log use the spark_log()
spark_log(sc, n=10)

# disconnect spark connection
spark_disconnect(sc)



